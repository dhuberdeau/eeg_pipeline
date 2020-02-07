function data = epoch_events(input_dir, input_file, trigger_value, input_parameters)
% function data = epoch_events(input_file, input_parameters)
%
% Function to epoch events defined by the trigger value trigger. Loads the data
% at [input_parameters.input_dir]/[input_file] and saves the signals from all
% channels from a window in the range
%     [input_parameters.pre_trig_time, input_parameters.post_trig_time]
%
% Input:
%   input_file - name of the .mat file where pre-processed input data is stored
%   trigger_value - value of the trigger for which to search
%   input_parameters - structure with fields:
%     - pre_trig_time - how many seconds before the trigger event to begin epoch
%         window (default 1sec)
%     - post_trig_time - how many seconds after the trigger event to begin epoch
%         window (default 2sec)
%     - baseline_time - the time window [start_time, stop_time], in seconds,
%         relative to the trigger event to use as baseline for subtracting the
%         signal mean from the data (default [-.5 0]).
%
% Outputs:
%   data - a structure with the following fields:
%     - label - a cell with the channel labels
%     - fsample - the sampling rate used
%     - trial - a cell array indexed by trial number and each containing a
%         matrix of channels x signal-length
%     - time - a cell array indexed by trial number and each containing a matrix
%         of 1 x signal-length

% David Huberdeau, NTB label

%% manage inputs:
if isfield(input_parameters, 'pre_trig_time')
  pre_trig_time = input_parameters.pre_trig_time;
else
  pre_trig_time = -1;
end

if isfield(input_parameters, 'post_trig_time')
  post_trig_time = input_parameters.post_trig_time;
else
  post_trig_time = 2;
end

if isfield(input_parameters, 'baseline_time')
  baseline_time = input_parameters.baseline_time;
else
  baseline_time = [-1, 0];
end

%% load in the data
load([input_dir, filesep, input_file])

%% obtain the trigger channel and time
ch_inds = 1:length(dat.label);
trig_ind = ch_inds(strcmp(dat.label, 'TRIG'));
trig_channel = dat.trial{1}(trig_ind, :);
time = dat.time{1};

%% obtain the indicies and times of trigger events.
signal_inds = 1:length(time);
trigger_inds = signal_inds(trig_channel == trigger_value);
diff_trigger_inds = diff([0, trigger_inds]); % = 1 within and >> 1 btwn triggers
trig_onset_inds = trigger_inds(diff_trigger_inds > 10); %10 is just to account for
  % occasional erroneous trigger values within an otherwise valid trigger pulse
trig_onset_times = time(trig_onset_inds);
N_events = length(trig_onset_inds);

% define pre, post, and baseline indicies relative to event indicies:
inds_pre_trig = round(pre_trig_time*dat.fsample);
inds_post_trig = round(post_trig_time*dat.fsample);
inds_baseline = [round(dat.fsample*baseline_time(1)), round(dat.fsample*baseline_time(2))];

%% populate output data structure:
data.fsample = dat.fsample;
data.label = dat.label;
data.trial = cell(1, N_events);
data.time = cell(1, N_events);

for i_event = 1:length(trig_onset_inds)
  try
    % extract event data:
    event_data_mat = dat.trial{1}(:, trig_onset_inds(i_event) + (inds_pre_trig:inds_post_trig));
    event_time_mat = dat.time{1}(trig_onset_inds(i_event) + (inds_pre_trig:inds_post_trig));

    % subtract baseline:
    channel_baselines = nanmean(...
      event_data_mat(:, (inds_baseline(1):inds_baseline(2)) - inds_pre_trig + 1), 2);
    baselines_to_subtract = repmat(channel_baselines, 1, size(event_data_mat,2));

    data.trial{i_event} = event_data_mat - baselines_to_subtract;
    data.time{i_event} = event_time_mat - trig_onset_times(i_event);
  catch err_
    warning(['Error processing file ', input_file, ' on event ' num2str(i_event), '. ',...
    err_.message, ' on line ', num2str(err_.stack(1).line)]);
  end
end
