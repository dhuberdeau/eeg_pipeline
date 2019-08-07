% compute_TF_means.m
%
% Wrapper script for the main Time-Frequency (TF) analysis portion of the 
% main pipeline.
%
% This script computes the TF signal (filtered) and then computes the
% z-score signal (where the baseline of the signal is used as the
% distribution to compute the z-score of the rest of the erp signal). This
% is also filtered (technically smoothed, using a sgolayfilt function).
%
% The second state of this script computes features from the erp (z-score)
% signal, which in this case is the maximum absolute z-score within
% 1-second following the trigger. Triggers considered are pre-cue and
% target. This feature is averaged among channels within an ROI, defined
% from study of the anatomical MRI scans after electrode implantation. 
%
% Statistical analyses are done to test for differences among conditions 
% and epochs using computed features.
%
% TODO:
% Select target electrodes based on much more nuanced localization, and
% based on activation during actual movement.
%
%
% Author: David Huberdeau
% Date: 03/23/2019
% NTB Lab.

%% define constants and preliminaries:
data_directory_input = '/home/david/sandbox_4'; % for milgram (Greg's lab)
data_directory_output = '/home/david/sandbox_4/group_data';

%% define channel ROIs:

% setup for first stage of analysis: compute the erp signal and z-score
% signal

% parameters common to all subject:
erp_file_prefix = 'TF_signal_';
z_file_prefix = 'TF_zscore_';

% parameters unique to each subject:
sub_prefix = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P007', 'P008'};

% for hippocampal ROIs:
sub_ROI_chs_hipp = {...
    {'LH1', 'LH2', 'LH3', 'RH1', 'RH2', 'RH3'},...
    {'II1', 'II2', 'II3', 'HH1', 'HH2'},...% for first surgical implantation (which is when the first session of data was collected
    {'SS1', 'SS2', 'II1', 'II2'},...
    {'MM1', 'MM2', 'MM3', 'MM4'},... % better localization of hippocampus
    {'EE1', 'FF1', 'FF2'},...
    {'HH1', 'HH2', 'HH3', 'HH4', 'HH5', 'KK1', 'KK2'},...
    {'KK1', 'KK2', 'MM1', 'MM2', 'MM3', 'OO1', 'OO2'},...
    {'DD1', 'DD2', 'DD3'},...
    };

% for cortical ROIs:
sub_ROI_chs_cort = {...
    {'RAI9', 'RAI10', 'RAI11', 'LAI9', 'LAI10', 'LAI11'},...
    {'CC9', 'CC10', 'CC11', 'CC12'},...
    {'NN5', 'NN6', 'LL1', 'LL2', 'LL3', 'LL4', 'LL5', 'LL6', 'LL7', 'LL8', 'LL9', 'LL10', 'BB1', 'BB2', 'BB3', 'BB4', 'BB5', 'BB6', 'BB7', 'BB8', 'BB9', 'BB10'},...
    {'C1', 'C2', 'C3', 'C4', 'C5', 'C6'},...
    {},...
    {'O6', 'O7', 'O8'},...
    {'G14', 'G19'},...
    {'G38', 'G39', 'G40', 'G46', 'G47', 'G48', 'G54', 'G55', 'G56'},...
    };


% setup for second stage analysis: compute feature of erp signal (in this
% case, the maximum absolute z-score within the first second after the
% event).

% parameters common to all subject:
cond_suffix_cue = {...
    '_TF_event1_type0', '_TF_event1_type1', '_TF_event1_type2',...
    };

cond_suffix_targ = {...
    '_TF_event2_type0', '_TF_event2_type1', '_TF_event2_type2',...
    };

% parameters unique to each subject:
sub_chs_to_average_hipp = {{{'RH1', 'RH2'}, {'LH1', 'LH2'}},...
    {{'II1', 'II2', 'II3'}, {'HH1', 'HH2'}},...
    {{'SS1', 'SS2'}, {'II1', 'II2'}},...
    {{'MM1', 'MM2', 'MM3', 'MM4'}},...
    {{'FF1', 'FF2'}, {'EE1'}},...
    {{'HH1', 'HH2', 'HH3', 'HH4', 'HH5'}, {'KK1', 'KK2'}},...
    {{'MM1', 'MM2', 'MM3'}, {'OO1', 'OO2'}},...
    {{'DD1', 'DD2', 'DD3'}}};

sub_chs_to_average_cort = {...
    {{'RAI9', 'RAI10', 'RAI11'}, {'LAI9', 'LAI10', 'LAI11'}},...
    {{'CC9', 'CC10', 'CC11', 'CC12'}},...
    {{'NN5', 'NN6'}, {'LL1', 'LL2', 'LL3', 'LL4', 'LL5', 'LL5', 'LL6', 'LL7', 'LL8', 'LL9', 'LL10'}, ...
    {'BB1', 'BB2', 'BB3', 'BB4', 'BB5', 'BB6', 'BB7', 'BB8', 'BB9', 'BB10'}},...
    {{'C1', 'C2', 'C3', 'C4', 'C5', 'C6'}},...
    {},...
    {{'O6', 'O7', 'O8'}},...
    {{'G14', 'G19'}},...
    {{'G38', 'G39', 'G40', 'G46', 'G47', 'G48', 'G54', 'G55', 'G56'}}};

%% find channel numbers corresponding to channel labels for each subject:
% sub_ROI_hipp_chNo = cell(1,8);
% for i_sub = 1%:length(sub_prefix)
%     raw_inds = 1:size(
% end
i_sub = 8;
ch_labels = cell(1, length(EEG.chanlocs));
for i_loc = 1:length(EEG.chanlocs)
    ch_labels{i_loc} = EEG.chanlocs(i_loc).labels;
end

raw_inds = 1:length(ch_labels);
roi_hipp_chNo = nan(1, length(sub_ROI_chs_hipp{i_sub}));
for i_roi = 1:length(sub_ROI_chs_hipp{i_sub})
    roi_hipp_chNo(i_roi) = raw_inds(strcmp(ch_labels, sub_ROI_chs_hipp{i_sub}{i_roi}));
end

