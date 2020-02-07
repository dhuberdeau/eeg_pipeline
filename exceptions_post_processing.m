%% use this script to fix / modify trials if exceptions are discovered after processing.

% Patient PSL003:
% Problem:
%   Triggers did not register properly for 2 trials in this patient's data.
%   The trials are 2 and 62 (indexed to the behavioral data, which captured all
%   trials).
% Solution:
%   Add empty (nan) matrix of eeg data for those two trials. Alternative would be to remove
%   those trials from behavior, but I would rather take a strategy of maximizing data retention.
%

data_dir = '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data';
data_file = 'CH_vma_comb14.h5';

data = hdf5read([data_dir, filesep, data_file], '/data');

% insert empty matricies at trials 2 and 62.
data = cat(1, cat(1, cat(1, data(1,:,:), nan(1, size(data,2), size(data,3))),...
cat(1, data(2:60,:,:), nan(1, size(data,2), size(data,3)))),...
data(61:end,:,:));

hdf5write([data_dir,...
filesep,...
data_file(1:(end-3)), '_fix', '.h5'], '/data', data);
