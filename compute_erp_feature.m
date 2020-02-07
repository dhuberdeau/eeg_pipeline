function [feature, varargout] = compute_erp_feature(input_file, time_window)
% feature = compute_erp_feature(input_file, time_window)
%
% Function to compute the ERP feature (a z-score, based on the baseline window
% signal, of the magnitude of the response after the trigger event).
%
% Inputs:
%   (1) input_file - the file location (possibly including full path) of the
%                   data. Must be in hdf5 format with '/data' field that has a
%                   matrix of values in the shape trials x channels x signal.
%   (2) time_window - the beginning and end times over which to compute the feature.
%
% David Huberdeau, 01/23/2020
try
%% define constants: make these parameters or globals at some point?
N_POINTS = 1537; % at 512hz sampling rate with a window of 3-sec.
Fs = 512;
FILT_LEN = 31;
FILT_ORDER = 3;

%% define time
time = (0:(N_POINTS-1))/Fs - 1;
baseline_inds = time < 0;
signal_inds = time >= 0;
timewind_inds = time > time_window(1) & time <= time_window(2);

%% load the data:
h_inf = h5info(input_file);
assert(isequal(h_inf.Datasets.Name, 'data'), ...
['Dataset ', input_file, 'does not contain data.']);
data = h5read(input_file, '/data');

%% filter and process data:

% smooth:
data_sm = nan(size(data));
for i_ch = 1:size(data,2)
    for i_tr = 1:size(data,1)
        data_sm(i_tr, i_ch, :) = sgolayfilt(data(i_tr, i_ch, :), FILT_ORDER, FILT_LEN);
    end
end

%% define output structure:
feature = nan(size(data,1), size(data,2)); %trials x channels

%% z-score computation:

data_z = nan(size(data_sm));
for i_ch = 1:size(data_sm,2)
    baseline_ch_mean = nanmean(...
    reshape(data_sm(:, i_ch, baseline_inds), size(data_sm,1)*sum(baseline_inds), 1));
    baseline_ch_sd = nanstd(...
    reshape(data_sm(:, i_ch, baseline_inds), size(data_sm,1)*sum(baseline_inds), 1));

    data_z(:, i_ch, :) = (data_sm(:, i_ch, :) - baseline_ch_mean)/baseline_ch_sd;
end

%% compute feature for each trial and channel:
for i_ch = 1:size(data_z,2)
  for i_tr = 1:size(data_z,1)
    % smooth the signal some:
    % some kind of smoother here.
    data__ = data_z(i_tr, i_ch, timewind_inds);
    data_ = reshape(data__, size(data__,3), 1);

%     data_ = sgolayfilt(data_, FILT_ORDER, FILT_LEN);

    % extract feature:
    feature(i_tr, i_ch) = nanmean(data_);
  end
end

catch err
  warning('A erp feature error occured.')
  warning([err.message '. '])
end

if exist('err', 'var')
    varargout{1} = err;
    feature = nan;
else
    varargout{1} = [];
end
