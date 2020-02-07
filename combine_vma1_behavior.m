
% Each subject has behavioral data in files called 'behavior_all_x.mat'.
% These files hold a variable called rt, which is a 1x3 cell arrays. Each cell
% is a matrix with dimensions n-trials x 3, with 3 being for [rt, type, target].

% We want these to be condensed to a single cell array with 1xN_subs cells, each
% containing a matrix of dimension n-trials x 3, where n-trials matches the
% first dimension of the subject's EEG record.

% David Huberdeau

data_dir = '/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data';

addpath(data_dir);

subject_list = {'LL', 'DO', 'JB', 'BP', 'VS', 'JK', 'LO', 'NH'};

rt_set = cell(1, length(subject_list));
for i_sub = 1:length(subject_list)
  load(['behavior_all_', num2str(i_sub)]);

  rt_sub = [rt{1}; rt{2}; rt{3}];

  rt_set{i_sub} = rt_sub;
end

save([data_dir, filesep, 'rt_set_vma1.mat'], 'rt_set');
