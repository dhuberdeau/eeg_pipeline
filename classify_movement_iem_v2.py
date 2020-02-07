# Load necessary software packages
import numpy as np
import scipy.io as sio
import h5py
import random
import matplotlib.pyplot as plt
from sklearn import tree
from sklearn.svm import SVC
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
from sklearn.multiclass import OneVsRestClassifier
from sklearn.model_selection import train_test_split as split
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.decomposition import PCA
from sklearn.metrics import confusion_matrix
from scipy import stats
import logging
from sklearn.preprocessing import Imputer
# import brainiak.reconstruct.iem
from iem import InvertedEncoding

logger = logging.getLogger(__name__)
# logging.basicConfig(filename='classify.log',level=logging.DEBUG)

def custom_load_data(eeg_data_file, labels_file, behavior_data_file, subject_number):
    # extract the time-frequency decomposition data:
    # The file was saved as a matlab struct, and so have to drill down:

    # eeg_data loads with indicies as follows: [string][0][0][field][index]
    #    where string is the name of the variable, field is the index of the field, and
    #.   index is an index of the elements in that field.

    # now data is [TRIALS][FREQ x TIME x CHANNELS]
    # E.G. X_all[0][:,:,0] is a matrix for the first trial
    # with frequencies as first dimension,
    # time as second dimensaion, and on the first channel.

    sample_inds = np.array(range(512, 1537)) # this excludes the pre-stimulus signal period. (512Hz sampling)

    f = h5py.File(eeg_data_file)
    dat__ = f['data']
    dat_ = dat__[()]
    dat = np.transpose(dat_, [2, 0, 1])
    X_all = dat[:,sample_inds,:]

    y_all_ = sio.loadmat(behavior_data_file)
    y_all = y_all_['rt_set'][0][subject_number-1]
#     y_all = np.vstack((y_all__[0], y_all__[1], y_all__[2]))

#     channel_list_ = this_x['data'][0][0][0][0]
#     channel_list = [channel_list_[i_][0] for i_ in range(0, len(channel_list_))]
    channel_list_ = sio.loadmat(labels_file)
    channel_list = [channel_list_['data'][0][0][1][i_][0][0] for i_ in range(len(channel_list_['data'][0][0][1]))]

    return(X_all, y_all, channel_list)

def circ_dist(v1, v2):
    # compute the directional distance between two radial points v1 and v2
    # such that the result is the shortest angular distance between the two
    # points in degreeds. v1 and v2 should be in degrees.

    if v1 > 180:
        v1 = v1 - 360

    else:
        if v1 <= -180:
            v1 = v1 + 360

    if v2 > 180:
        v2 = v2 - 360

    else:
        if v2 <= -180:
            v2 = v2 + 360

    rd = v2 - v1

    if rd > 180:
        rd = rd - 360
    else:
        if rd < -180:
            rd = rd + 360

    return(rd)

def extract_channel_numbers(desired_channels, channel_list):
    ch_inds = np.array(range(0, len(channel_list)))
    desired_channel_inds_ = np.empty(len(desired_channels))
    for i_ch in range(len(desired_channels)):
        channel = desired_channels[i_ch]
        n_channel_ = ch_inds[[channel_list[i_] == channel for i_ in range(len(channel_list))]]
        n_channel = n_channel_[0]
        desired_channel_inds_[i_ch] = n_channel

    desired_channel_inds = [int(desired_channel_inds_[i_]) for i_ in range(len(desired_channel_inds_))]
    return(desired_channel_inds)

def condition_data(X_all, y_all, n_channel_list):
    shape_X = np.shape(X_all)
    X_vect = np.reshape(X_all[:,:,n_channel_list], (shape_X[0], shape_X[1]*len(n_channel_list)))
    retain_trials_X = np.sum(np.isnan(X_vect), axis=1)==0
    retain_trials_y = np.isnan(y_all[:,0]) == 0
    retain_trials = [retain_trials_X[i_] and retain_trials_y[i_] for i_ in range(0, len(retain_trials_y))]
    X_vect_clean = X_vect[retain_trials, :]
    y_clean = y_all[retain_trials, :]

    return(X_vect_clean, y_clean)

def condition_reduce_data(X_all, y_all, n_channel_list):

    # exclude trials with any nan value. This isn't supposed to happen, but
    # might if a file needed trial padding because of a bad clipping from Natus
    # From my experience, this happens to ALL channels, so only check one:
    retain_trials_X = np.sum(np.isnan(X_all[:,:,n_channel_list[0]]), axis=1)==0
    retain_trials_y = np.isnan(y_all[:,0]) == 0
    retain_trials = [retain_trials_X[i_] and retain_trials_y[i_] for i_ in range(0, len(retain_trials_y))]
    X_all_clean = X_all[retain_trials, :, :]
    y_all_clean = y_all[retain_trials, :]

    n_comp = 4;
    X_dims = np.shape(X_all_clean)
    X_reduce = np.empty((X_dims[0], n_comp*len(n_channel_list)))
    k_ind = 0
    for i_ch in range(len(n_channel_list)):
        pca = PCA(n_components = n_comp)
        X_reduce_ch = pca.fit_transform(X_all_clean[:, :, n_channel_list[i_ch]])
        X_reduce[:,k_ind:(k_ind + n_comp)] = X_reduce_ch
        k_ind = k_ind + n_comp

    retain_trials_X = np.sum(np.isnan(X_reduce), axis=1)==0
    retain_trials_y = np.isnan(y_all_clean[:,0]) == 0
    retain_trials = [retain_trials_X[i_] and retain_trials_y[i_] for i_ in range(0, len(retain_trials_y))]
    X_vect_clean = X_reduce[retain_trials, :]
    y_clean = y_all_clean[retain_trials, :]

    return(X_vect_clean, y_clean)

def custom_unwrap(raw_diff):
    raw_diff[raw_diff > 180] = raw_diff[raw_diff > 180] - 360
    raw_diff[raw_diff < -180] = raw_diff[raw_diff < -180] + 360
    return(raw_diff)

def custom_inv_enc(X_vect_clean, y_clean):
    # test regression of trial type (no-cue, direct cue, or symbolic cue)
    # from neural data. Return average score, score of shuffled data as comparison
    # and a confusion matrix (confusion matrix to be added later).

    def pred_score(X, y):
        # split the data into train and test, and train iem
        X_train, X_test, y_train, y_test = split(X, y, test_size=0.5)
        rgs.fit(X_train, y_train)

        # predict the response in test cases:
        pred_iem = rgs.predict(X_test)
        err_iem = [circ_dist(pred_iem[i_], y_test[i_]) for i_ in range(len(pred_iem))]

        # score the test cases:
        u = np.sum([err_iem[i_]**2 for i_ in range(len(err_iem))])
        v = 90**2
        score_rgs = 1 - u/v

        # compute reconstruction:
        recon = rgs._predict_direction_responses(X_test)

        # score classifier and get average reconstructions per category:
        cat_predict = []
        for i_tr in range(0,len(pred_iem)):
#             targ_dist = np.abs(pred_iem[i_tr] - targ_directions)
            targ_dist = [np.abs(circ_dist(pred_iem[i_tr], targ_directions[i_targ]))
                         for i_targ in range(len(targ_directions))]
            targ_match = np.argmin(targ_dist)
            cat_predict.append(targ_directions[targ_match])

        cls_hits = [cat_predict[i_] == y_test[i_] for i_ in range(len(y_test))]
        score_cls = np.sum(cls_hits)/len(cls_hits)

        recon_cat = np.empty((3,180))
        for i_cat in range(0, len(targ_directions)):
            d_cat = [recon[:,x] for x in range(0, len(cat_predict))
                     if cat_predict[x] == targ_directions[i_cat]]
            recon_cat[i_cat, :] = np.mean(d_cat,0)

        return(score_rgs, score_cls, recon_cat)

    # some constants:
    y_dim = 2 #y_dim of 2 is movement direction, #y_dim of 1 is trial type.

    # some algorithm parameters:
    n_reps = 500

    # define the classifier:
    rgs = InvertedEncoding(6, 4, -30, 300)

    # lda = LDA()
    # X_decomp = lda.fit_transform(X_vect_clean, y_clean[:,y_dim])
    X_decomp = np.copy(X_vect_clean)

    targ_directions = [10, 130, 250]
    int_inds = [int(y_clean[i_,2]) for i_ in range(np.shape(y_clean)[0])]
    y_continuous = [targ_directions[i_-1] for i_ in int_inds]

    score_set = np.empty(n_reps)
    clf_set = np.empty(n_reps)
    recon_set = np.empty((3, 180, n_reps))
    for i_set in range(0,n_reps):
        (score, score_cls, recon_cat) = pred_score(X_decomp, y_continuous)

        score_set[i_set] = score
        clf_set[i_set] = score_cls
        recon_set[:, :, i_set] = recon_cat


    score_rand = np.empty(n_reps)
    clf_rand = np.empty(n_reps)
    recon_rand = np.empty((3, 180, n_reps))
    y_rand = y_continuous.copy()
    for i_set in range(0,n_reps):
        np.random.shuffle(y_rand)
        (score, score_cls, recon_cat) = pred_score(X_decomp, y_rand)

        score_rand[i_set] = score
        clf_rand[i_set] = score_cls
        recon_rand[:, :, i_set] = recon_cat

    return(score_set, score_rand, clf_set, clf_rand, recon_set, recon_rand)

def custom_unwrap(raw_diff):
    raw_diff[raw_diff > 180] = raw_diff[raw_diff > 180] - 360
    raw_diff[raw_diff < -180] = raw_diff[raw_diff < -180] + 360
    return(raw_diff)
## Define parameters:

# desired channels list hippocampal, motor-cortical, and control contacts for each subject
desired_channel_set = [[['MM1', 'MM2', 'MM3'],
    ['LL1', 'LL2', 'LL3'],
    ['HH1', 'HH2', 'HH3'],
    ['RHc1', 'RHc2', 'LHc1', 'LHc2']],
    [['AA1', 'AA2', 'AA3', 'AA4', 'AA5', 'AA6'],
    ['G16', 'G24', 'G32','G15','G23', 'G31', 'G14', 'G22', 'G30', 'G13', 'G21', 'G29'],
    ['LF4','LF5','LF6','G24','G32','G40'],
    ['RSma1','RSma2','RSma3','RSma4','LSMa1','LSMa2','LSMa3','LSMa4']],
    [['MM5', 'MM6', 'MM7'],
    ['LL4', 'LL5', 'LL6'],
    ['HH4', 'HH5', 'HH6'],
    ['RHc4', 'RHc5', 'LHc4', 'LHc5']]]

# data_dir = '/Users/david/Box Sync/iEEG/AnalysisScripts/intermediate_data/'
data_dir = '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data/'

subject_initials = ['DG_vma_comb', 'CF_vma_comb_short', 'WL_vma_comb', 'DR_vma_comb']
subject_number_in_rt_set = [1, 2, 4, 5] #indexed as in matlab
epoch = ['15', '170'] # for some reason, movement epoch is producing errors??
epoch_per_sub = [['15', '15', '14', '15'], ['170','170','170','170']]
types = [0,1,2]
roi = ['hip', 'cor', 'cnt']
behavior_file = 'rt_set_short.mat'

## main portion: Run classifier on subjects with specified parameters: ##
score_all = np.empty((len(epoch), len(roi), len(subject_initials)))
rscore_all = np.empty((len(epoch), len(roi), len(subject_initials)))
dscore_all = np.empty((len(epoch), len(roi), len(subject_initials)))
pval_all = np.empty((len(epoch), len(roi), len(subject_initials)))
tstat_all = np.empty((len(epoch), len(roi), len(subject_initials)))

recon_all = np.empty((len(epoch), len(roi), len(subject_initials), 3, 180))
recon_all_rand = np.empty((len(epoch), len(roi), len(subject_initials), 3, 180))

for i_epoch in range(0,len(epoch)):
    for i_roi in range(0, len(roi)):
        for i_sub in range(0, len(subject_initials)):
            try:
                # data_files = []
                # for i_type in range(0, len(types)):
                #     # data_files = np.append(data_files, data_dir+subject_initials[i_sub]+'_'+epoch[i_epoch]+'_'+str(types[i_type])+'_TF_'+roi[i_roi]+'.mat')
                #     data_files = np.append(data_files, data_dir+subject_initials[i_sub]+'_'+epoch[i_epoch]+'_'+str(types[i_type])+'.mat')
                # behavior_file = data_dir+behavior_prefix+str(i_sub+1)+'.mat'

                desired_channels = desired_channel_set[i_roi][i_sub]

                eeg_data_file = data_dir+subject_initials[i_sub]+epoch_per_sub[i_epoch][i_sub]+'.h5'
                behavior_data_file = data_dir+behavior_file
                label_file = data_dir+subject_initials[i_sub]+epoch_per_sub[i_epoch][i_sub]+'_labels.mat'

                X_all, y_all, ch_all = custom_load_data(eeg_data_file,
                                                label_file,
                                                behavior_data_file,
                                                subject_number_in_rt_set[i_sub])
                desired_channel_nums = extract_channel_numbers(desired_channels, ch_all)
                X_vect_clean, y_clean = condition_reduce_data(X_all, y_all, desired_channel_nums)

                # combine like targets:
                y_clean[y_clean[:,2] == 4, 2] = 1
                y_clean[y_clean[:,2] == 5, 2] = 2
                y_clean[y_clean[:,2] == 6, 2] = 3
                score, rand_score, clf_score, clf_rand, recon_set, recon_rand = custom_inv_enc(X_vect_clean, y_clean)

                score_all[i_epoch][i_roi][i_sub] = np.mean(clf_score)
                rscore_all[i_epoch][i_roi][i_sub] = np.mean(clf_rand)
                dscore_all[i_epoch][i_roi][i_sub] = np.mean(clf_score) - np.mean(clf_rand)
                # The order of dimensions here is opposite in Matlab.
                # In matlab it is: (sub, roi, epoch)

                this_t, this_p = stats.ttest_ind(clf_score,clf_rand)
                pval_all[i_epoch][i_roi][i_sub] = this_p
                tstat_all[i_epoch][i_roi][i_sub] = this_t

                temp_mean = np.mean(recon_set,axis=2)
                for i_cat in range(np.shape(recon_all)[0]):
                    recon_all[i_epoch][i_roi][i_sub][i_cat][:] = temp_mean[i_cat,:]

                temp_mean = np.mean(recon_rand,axis=2)
                for i_cat in range(np.shape(recon_all_rand)[0]):
                    recon_all_rand[i_epoch][i_roi][i_sub][i_cat][:] = temp_mean[i_cat,:]

                print('Score: ', np.mean(clf_score))
                print('Rand Score: ', np.mean(clf_rand))
                print('Diff Score: ', np.mean(clf_score) - np.mean(clf_rand))
            except:
                print('There was an error for subject: ', str(i_sub))
                # raise

f = h5py.File('score_data_targetIEM_all_reduce.hdf5', 'w')
dset = f.create_dataset('score', data=score_all)
dset = f.create_dataset('rscore', data=rscore_all)
dset = f.create_dataset('dscore', data=dscore_all)
dset = f.create_dataset('pval', data=pval_all)
dset = f.create_dataset('tstat', data=tstat_all)
dset = f.create_dataset('recon_all', data=recon_all)
dset = f.create_dataset('recon_all_rand', data=recon_all_rand)
f.close()
