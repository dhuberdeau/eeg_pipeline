function fieldtrip_preprocessing_func(raw_data_dir, data_file, input_parameters, output_prefs)
%
%
% function = fieldtrip_preprocessing_func(raw_data_dir, data_file, input_parameters, output_prefs)
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
%   - save at each step if specified to do so.
% Redesign of version that used EEGLAB. This version uses fieldtrip for
% preprocessing, but otherwise does the same computations.
%
% Inputs:
%   raw_data_dir = the directory where the raw data file is to be found.
%   data_file = the name of the data file
%   input_parameters = structure that specifies pre-processing parameters:
%     (1) filter_cutoff (default 256Hz)
%     (2) downsample_rate
%     (3) channels_to_remove (which can be empty)
%   output_prefs = structure indicating output parameters, including:
%     (1) output_dir
%     (2) output_file (name of output file prefix.)
%     (3) files_to_save (options: 'raw', 'filt', 'downsamp'); saves downsamp by default
%
% This script generates two output files - [output_file]_trig.mat and [output_file]_512hz.mat
% ------------------------------------------------

%% check for proper inputs, and use defaults if not given:
if isfield(input_parameters, 'filter_cutoff')
  LOW_PASS_FILT_CUTOFF_FRQ = input_parameters.filter_cutoff;
else
  LOW_PASS_FILT_CUTOFF_FRQ = 256;
end
if isfield(input_parameters, 'downsample_rate')
  RESAMPLE_RATE = input_parameters.downsample_rate;
else
  RESAMPLE_RATE = 512;
end
if isfield(input_parameters, 'channels_to_remove')
  channels_to_remove = input_parameters.channels_to_remove;
else
  channels_to_remove = {};
end
% other required inputs:
output_dir = output_prefs.output_dir;
output_file = output_prefs.output_file;

rm_channels = ~isempty(channels_to_remove);

addpath('/gpfs/milgram/project/turk-browne/projects/StatLearning_iEEG/fieldtrip')
ft_defaults

%% load raw data file
% Set up the parameters for loading the data
cfg            = [];
cfg.dataset    = [raw_data_dir, data_file];
cfg.continuous = 'yes';
cfg.channel    = 'all'; % For testing: {'Event' 'LH1', 'TRIG'};
cfg.refchannel = 'all';
% Extract the data with the specified parameters
data           = ft_preprocessing(cfg);
if ismember('raw', output_prefs.files_to_save)
    if ~exist([output_dir, data_file, '_raw.set'], 'file')
        ft_write_data([output_dir, output_file, '_raw'], data, 'dataformat', 'matlab');
    end
end

%% Extract trigger channel for inspection
trigger_ind = strcmp(data.label, 'TRIG');
trig_channel = data.trial{1}(trigger_ind,:);
save([output_dir, output_file, '_trig'], 'trig_channel');

% Second method of loading data to extract trigger channel (used b.c there is a
%  problem with triggers loaded from fieldtrip (and eeglab))
[hdr, record] = edfread(cfg.dataset);
trigger = record(strcmp(hdr.label, 'TRIG'), :);
trigger_set = unique(trigger);
if sum((trigger_set > 0) > 0)
    % trigger is correct sign
else
    trigger = -trigger;
    trigger_set = unique(trigger);
    if sum((trigger_set > 0) > 0)
        % trigger is now the correct sign
    else
        % something is wrong with this trigger
        error('Trigger not properly found');
    end
end

%% filter data
cfg.lpfilter = 'yes';
cfg.lpfreq = LOW_PASS_FILT_CUTOFF_FRQ;
rmfield(cfg, 'dataset'); % additional processing done on data variable, not raw file.
data = ft_preprocessing(cfg, data);
if ismember('filt', output_prefs.files_to_save)
    if ~exist([output_dir, data_file, '_filt.set'], 'file')
        ft_write_data([output_dir, output_file, '_filt'], data, 'dataformat', 'matlab');
    end
end

%% resample data
cfg.resamplefs = RESAMPLE_RATE; % What frequency do you want to down sample to
cfg.method = 'resample';
cfg.detrend = 'no';
cfg.demean = 'no';
cfg.baselinewindow = 'all';
cfg.sampleindex = 'no';
data = ft_resampledata(cfg, data);

% Downsample trigger without smoothing for exact values:
resample_factor = round(data.cfg.origfs/RESAMPLE_RATE);
trig_sig = downsample(trig_channel, resample_factor); %8 assumes a 512 re-sample rate; must

% place trigger channel back in:
if length(trig_sig) > size(data.trial{1}, 2)
  inds_to_use = 1:length(trig_sig);
  diff_len = length(trig_sig) - size(data.trial{1}, 2);
  inds_to_use = inds_to_use((floor(diff_len/2)+1):(length(inds_to_use) - ceil(diff_len/2)));
  data.trial{1}(trigger_ind, :) = trig_sig(inds_to_use);
elseif length(trig_sig) < size(data.trial{1}, 2)
  diff_len =  size(data.trial{1}, 2) - length(trig_sig);
  trig_sig_padded = [zeros(1, floor(diff_len/2)), trig_sig, zeros(1, ceil(diff_len/2))];
  data.trial{1}(trigger_ind, :) = trig_sig_padded;
else
  data.trial{1}(trigger_ind, :) = trig_sig;
end

% always save downsamp version:
ft_write_data([output_dir, output_file, '_512hz'], data, 'dataformat', 'matlab');
