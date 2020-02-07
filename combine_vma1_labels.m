
% Create files that have data.label field only (so they are much smaller)

data_dir = '/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data';

addpath(data_dir)

subject_initials = {...
'LL', 'DO', 'BP', 'JB', 'JK', 'LO', 'NH', 'VS'};

file_epoch = 'precues';

types = 0;

for i_sub = 1:length(subject_initials)
  load([subject_initials{i_sub}, '_', file_epoch, '_', num2str(types), '.mat']);

  data = rmfield(data, 'trial');
  data = rmfield(data, 'time');

  save([data_dir, filesep, subject_initials{i_sub}, '_labels.mat'], 'data');
end
