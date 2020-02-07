% make sure there are the same number of trials in behavior data and in eeg data
data_dir = '/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data';

subject_list = {'LL', 'DO', 'JB', 'BP', 'VS', 'JK', 'LO', 'NH'};

n_count_eeg = nan(length(subject_list), 3);
n_count_beh = nan(length(subject_list), 1);

load([data_dir, filesep, 'rt_set_vma1.mat']);

for i_sub = 1:length(subject_list)
  n_count_beh(i_sub) = length(rt_set{i_sub});

  d = h5read([data_dir, filesep, subject_list{i_sub}, '_vma_comb_precues.h5'], '/data');
  n_count_eeg(i_sub,1) = size(d, 1);

  d = h5read([data_dir, filesep, subject_list{i_sub}, '_vma_comb_target.h5'], '/data');
  n_count_eeg(i_sub,2) = size(d, 1);

  d = h5read([data_dir, filesep, subject_list{i_sub}, '_vma_comb_movement.h5'], '/data');
  n_count_eeg(i_sub,3) = size(d, 1);

end
