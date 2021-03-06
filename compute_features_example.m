% script to compute features for all intermediate data files:

% David Huberdeau, NTB lab

%% For VMA2 experiment:
% data_dir = {...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
% '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data'};
%
% data_files = {...
%     'DG_vma_comb15.h5',...
%     'CF_vma_comb_short15.h5',...
%     'CH_vma_comb14_fix.h5',...
%     'WL_vma_comb14.h5',...
%     'DR_vma_comb15.h5',...
%     'DC_vma_comb15.h5',...
%     'PL_vma_comb15.h5',...
%     'RW_vma_comb15.h5',...
%     'MS_vma_comb15.h5',...
%     'DRJan_vma_comb15.h5'...
%   };
%
% label_files = {...
%     'DG_vma_comb15_labels.mat',...
%     'CF_vma_comb_short15_labels.mat',...
%     'CH_vma_comb14_fix_labels.mat',...
%     'WL_vma_comb14_labels.mat',...
%     'DR_vma_comb15_labels.mat',...
%     'DC_vma_comb15_labels.mat',...
%     'PL_vma_comb15_labels.mat',...
%     'RW_vma_comb15_labels.mat',...
%     'MS_vma_comb15_labels.mat',...
%     'DRJan_vma_comb15_labels.mat'...
% };

%% For VMA1 experiment:
data_dir = {...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data'};

subject_list = {'LL', 'DO', 'JB', 'BP', 'VS', 'JK', 'LO', 'NH'};
data_files = {...
    'LL_vma_comb_precues.h5',...
    'DO_vma_comb_precues.h5',...
    'JB_vma_comb_precues.h5',...
    'BP_vma_comb_precues.h5',...
    'VS_vma_comb_precues.h5',...
    'JK_vma_comb_precues.h5',...
    'LO_vma_comb_precues.h5',...
    'NH_vma_comb_precues.h5',...
  };

label_files = {...
  'LL_precues_0.mat',...
  'DO_precues_0.mat',...
  'JB_precues_0.mat',...
  'BP_precues_0.mat',...
  'VS_precues_0.mat',...
  'JK_precues_0.mat',...
  'LO_precues_0.mat',...
  'NH_precues_0.mat',...
};

sub_channels = {...
    {'LH1', 'LH2', 'LH3', 'RH1', 'RH2', 'RH3'},...
    {'II1', 'II2', 'II3', 'HH1', 'HH2'},...% for first surgical implantation (which is when the first session of data was collected
    {'SS1', 'SS2', 'II1', 'II2'},...
    {'MM1', 'MM2', 'MM3', 'MM4'},... % better localization of hippocampus
    {'EE1', 'FF1', 'FF2'},...
    {'HH1', 'HH2', 'HH3', 'HH4', 'HH5', 'KK1', 'KK2'},...
    {'KK1', 'KK2', 'MM1', 'MM2', 'MM3', 'OO1', 'OO2'},...
    {'DD1', 'DD2', 'DD3'},...
    };

rt_data_file = 'rt_set_vma1.mat';

output_dir = '/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data';

example_subject = 4;
example_channel = 1;

% load RT set
load([data_dir{example_subject}, filesep, rt_data_file]);

% loop through all files:
i_sub = example_subject;

% load channel labels:
load([data_dir{i_sub}, filesep, label_files{i_sub}]);
inds = 1:length(data.label);
k_ind = inds(strcmp(data.label, sub_channels{i_sub}{example_channel}));

% load the data from it's hdf5 format:
[signals, features, f_err] = compute_erp_feature_example(...
    [data_dir{i_sub}, filesep, data_files{i_sub}], [.25, .75], k_ind);

% save data data features in matlab format (bc they are going to be
% much smaller).
save([output_dir, filesep, data_files{i_sub}(1:3), '_erp_data.mat'],...
    'features');

f1 = figure;
subplot(1,2,1); hold on;
plot(signals(rt_set{example_subject}(:,2) == 0, :)', 'r-');
plot(signals(rt_set{example_subject}(:,2) == 1, :)', 'g-');
plot(signals(rt_set{example_subject}(:,2) == 2, :)', 'b-');
subplot(1,2,2); hold on;
plot(nanmean(signals(rt_set{example_subject}(:,2) == 0, :)), 'r-');
plot(nanmean(signals(rt_set{example_subject}(:,2) == 1, :)), 'g-');
plot(nanmean(signals(rt_set{example_subject}(:,2) == 2, :)), 'b-');

saveas(f1, [output_dir, filesep, data_files{example_subject}(1:3),...
 sub_channels{example_subject}{example_channel},...
 '_example_erp.png'], 'png');
