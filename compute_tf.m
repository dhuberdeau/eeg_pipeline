% script to process all intermediate data files into TF decompositions

% David Huberdeau, NTB lab

data_dir = {...
'/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data',...
'/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data'};
% data_dir = {'/Users/david/Box Sync/iEEG/vma_statlearning/intermediate_data'};

data_files = {...
  'DC_vma_comb15.h5',...
  'PL_vma_comb15.h5',...
  'RW_vma_comb15.h5',...
  'MS_vma_comb15.h5'...
  };

label_files = {...
'DC_vma_comb15_labels.mat',...
'PL_vma_comb15_labels.mat',...
'RW_vma_comb15_labels.mat',...
'MS_vma_comb15_labels.mat'...
};
% h5_files = {'DG_vma_comb15.h5', 'CF_vma_comb_short15.h5', 'CH_vma_comb14_fix.h5', 'WL_vma_comb14.h5'};

output_dir = '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data';

% loop through all files:
for i_sub = 1:length(data_files)
%   load([data_dir{i_sub}, filesep, data_files{i_sub}])
    datmat = hdf5read([data_dir{i_sub}, filesep, data_files{i_sub}], 'data');
    load([data_dir{i_sub}, filesep, label_files{i_sub}])
    data.trial = cell(1, size(datmat,1));
    for i_tr = 1:size(datmat,1)
        data.trial{i_tr} = reshape(datmat(i_tr, :,:), size(datmat,2), size(datmat,3));
    end
    tf_data = matlab_TF_computation(data);
    % save data as an hdf5 format becuase other programs (e.g. python) may have
    % trouble reading -v7.3 matlab files
    data_all = nan(length(tf_data.trial), size(tf_data.trial{1}, 1),...
    size(tf_data.trial{1}, 2), size(tf_data.trial{1}, 3));
    for i_trial = 1:length(tf_data.trial)
        try
          % get difference from pre-event baseline, for each channel:
          for i_ch = 1:size(tf_data.trial{1},3)
              p_temp = tf_data.trial{i_trial}(:,:,i_ch);
              p_baseline = repmat(nanmean(p_temp(:, tf_data.time{i_trial} < 0), 2), 1, size(p_temp,2));
              data_all(i_trial, :, :, i_ch) = p_temp - p_baseline;
          end
        catch
          warning(['An error occured: subject ', num2str(i_sub), ', trial ', num2str(i_trial)]);
        end
    end
    h5create([output_dir, filesep, data_files{i_sub}(1:(end-3)), '_TF_large.h5'], ...
        '/tf_data', size(data_all));
    h5create([output_dir, filesep, data_files{i_sub}(1:(end-3)), '_TF_large.h5'], ...
        '/time', size(tf_data.time{1}));
    h5create([output_dir, filesep, data_files{i_sub}(1:(end-3)), '_TF_large.h5'], ...
        '/freq', size(tf_data.freq{1}));
    h5write([output_dir, filesep, data_files{i_sub}(1:(end-3)), '_TF_large.h5'], ...
        '/tf_data', data_all);
    h5write([output_dir, filesep, data_files{i_sub}(1:(end-3)), '_TF_large.h5'], ...
        '/time', tf_data.time{1});
    h5write([output_dir, filesep, data_files{i_sub}(1:(end-3)), '_TF_large.h5'], ...
        '/freq', tf_data.freq{1});
    % save([output_dir, filesep, data_files{i_sub}(1:(end-4)), '_TF.mat'], 'tf_data', '-v7.3');
end
