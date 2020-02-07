function fieldtrip_combine_sessions(input_dir, data_files, input_parameters, output_prefs)
%
%
% function = fieldtrip_combine_sessions(raw_data_dir, data_files, input_parameters, output_prefs)
%
% First analysis stage for EEG data. Designed to run on the Milgram cluster
% using the fieldtrip software package.
%
% Steps:
%   - load data
%   - filter data (256Hz)
%   - downsample data (512Hz)
%   - remove baseline
%   - Fix trigger channels if values were erronious (this happens quite often, actually)
%   - remove empty channels
%   - Select events from TRIG channel
%   - save at each step if specified to do so.
% Redesign of version that used EEGLAB. This version uses fieldtrip for
% preprocessing, but otherwise does the same computations.
%
% Inputs:
%   raw_data_dir = the directory where the raw data file is to be found.
%   data_files = the name of the data file
%   input_parameters = structure with at least the following fields:
%     (1) filter_cutoff
%     (2) downsample_rate
%     (3) channels_to_remove (which can be empty)
% ------------------------------------------------

%% check for proper inputs, and use defaults if not given:
if isfield(input_parameters, 'intended_triggers')
  epoch_data = 1;
  intended_triggers = input_parameters.intended_triggers;
else
  epoch_data = 0;
  intended_triggers = [];
end
if isfield(input_parameters, 'actual_triggers')
  actual_triggers = input_parameters.actual_triggers;
else
  actual_triggers = [];
end
if isfield(input_parameters, 'channels_to_remove')
  channels_to_remove = input_parameters.channels_to_remove;
else
  channels_to_remove = {};
end
% other required inputs:
output_dir = output_prefs.output_dir;
output_file = output_prefs.output_file; %single file of combined input files

rm_channels = ~isempty(channels_to_remove);

addpath('/gpfs/milgram/project/turk-browne/projects/StatLearning_iEEG/fieldtrip')
ft_defaults

%% remove those channels specified:

%% redefine triggers if necessary:
actual_triggers = intended_triggers;

%% epoch intermediate data
data_set = cell(length(intended_triggers), length(data_files));
for i_file = 1:length(data_files)
  if epoch_data
    epoch_params = struct('pre_trig_time',-1,...
      'post_trig_time', 2,...
      'baseline_time', [-.5, 0]);
    for i_trig_type = 1:length(intended_triggers)
      data = epoch_events(input_dir, data_files{i_file},...
       actual_triggers(i_trig_type), epoch_params);
      if sum(strcmp(output_prefs.files_to_save, 'epoch')) > 0
        save([output_dir, filesep, data_files{i_file}(1:(end-4)), '_epoch',...
         num2str(intended_triggers(i_trig_type)), '.mat'], 'data', '-v7.3');
      end
      data_set{i_trig_type, i_file} = data;
    end
  end
end

%% combine files
for i_trig_type = 1:length(intended_triggers)
  data = data_set{i_trig_type, 1};
  data_trial = data.trial;
  data_time = data.time;
  if size(data_set,2) > 1
    for i_file = 2:length(data_files)
      data = data_set{i_trig_type, i_file};
      data_trial = [data_trial, data.trial];
      data_time = [data_time, data.time];
    end
  end
  data = data_set{i_trig_type, 1};
  data.trial = data_trial;
  data.time = data_time;

  % save([output_dir, filesep, output_file, num2str(intended_triggers(i_trig_type)), '.mat'],...
  %  'data', '-v7.3');
  data_all = nan(length(data.trial), size(data.trial{1},1), size(data.trial{1},2)); %number of trials x number of channels x number of samples
  for i_trial = 1:length(data.trial)
    try
      data_all(i_trial,:,:) = data.trial{i_trial};
    catch
      warning(['Trial failed: trial ', num2str(i_trial)]);
    end
  end
  hdf5write([output_dir, filesep, output_file, num2str(intended_triggers(i_trig_type)), '.h5'],...
    '/data', data_all);

  % save the data structure without the actual data (which will be saved as .h5)
  data = rmfield(data, 'trial');
  save([output_dir, filesep, output_file, num2str(intended_triggers(i_trig_type)), '_labels.mat'],...
  'data');
end
