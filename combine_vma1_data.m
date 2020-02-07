% combine each subject's data into a single file with the format
% trials x channels x signal-length

% data is in files labeled XX_epoch_type.mat
% each file has a variable data, which has a field 'trial'. data.trial is in the
% format of a cell with length equal to the number of trials of that type.

% combine eeg data into matricies of dims [trials x channels x signal-length]
% and behavior data into n-trials x 3 (rt, type, target)
data_dir = '/gpfs/milgram/project/turk-browne/projects/vma_recall_iEEG/intermediate_data';

addpath(data_dir)

subject_initials = {...
'LL', 'DO', 'BP', 'JB', 'JK', 'LO', 'NH', 'VS'};

file_epoch = {'precues', 'movement', 'target'};

types = [0,1,2];

for i_sub = 1:length(subject_initials)
  for i_sufx = 1:length(file_epoch)
    load([subject_initials{i_sub}, '_', file_epoch{i_sufx}, '_', num2str(types(1)), '.mat']);
    data_mat = zeros([0, size(data.trial{1},1), size(data.trial{1},2)]);
    for i_type = 1:length(types)
      load([subject_initials{i_sub}, '_', file_epoch{i_sufx}, '_', num2str(types(i_type)), '.mat'])
      for i_tr = 1:length(data.trial)
        data_mat = cat(1, data_mat, ...
          reshape(data.trial{i_tr}, [1, size(data.trial{i_tr},1), size(data.trial{i_tr},2)]));
      end
    end
    h5create([data_dir, filesep, subject_initials{i_sub}, '_vma_comb_', file_epoch{i_sufx}, '.h5'],...
      '/data', size(data_mat));
    h5write([data_dir, filesep, subject_initials{i_sub}, '_vma_comb_', file_epoch{i_sufx}, '.h5'],...
      '/data', data_mat);
    % hdf5write([data_dir, filesep, subject_initials{i_sub}, '_vma_comb_', file_epoch{i_sufx}, '.h5'],...
    %   '/data', data_mat);
  end


end
