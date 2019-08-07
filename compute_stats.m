% compute_stats.m - a shortened version of compute_all_means.m
%
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
% Date: 05/22/2019
% NTB Lab.

%% define constants and preliminaries:
data_directory_input = '/home/david/sandbox_6'; % for milgram (Greg's lab)
data_directory_output = '/home/david/sandbox_6/group_data2';

%% which stats analysis version to use:
analyze_roi_erp_zscore = @(arg1, arg2, arg3, arg4, arg5) ...
    analyze_roi_erp_zscore5(arg1, arg2, arg3, arg4, arg5);

%% define channel ROIs:

% setup for first stage of analysis: compute the erp signal and z-score
% signal

% parameters common to all subject:
erp_file_prefix_precue_hipp = 'erp_signal_event1_hipp';
z_file_prefix_precue_hipp = 'erp_zscore_event1_hipp';

erp_file_prefix_target_hipp = 'erp_signal_event2_hipp';
z_file_prefix_target_hipp = 'erp_zscore_event2_hipp';

erp_file_prefix_movement_hipp = 'erp_signal_event3_hipp';
z_file_prefix_movement_hipp = 'erp_zscore_event3_hipp';

erp_file_prefix_ready_hipp = 'erp_signal_event4_hipp';
z_file_prefix_ready_hipp = 'erp_zscore_event4_hipp';

erp_file_prefix_precue_cort = 'erp_signal_event1_cort';
z_file_prefix_precue_cort = 'erp_zscore_event1_cort';

erp_file_prefix_target_cort = 'erp_signal_event2_cort';
z_file_prefix_target_cort = 'erp_zscore_event2_cort';

erp_file_prefix_movement_cort = 'erp_signal_event3_cort';
z_file_prefix_movement_cort = 'erp_zscore_event3_cort';

erp_file_prefix_ready_cort = 'erp_signal_event4_cort';
z_file_prefix_ready_cort = 'erp_zscore_event4_cort';

% parameters unique to each subject:
sub_prefix = {...
    'LL', 'DO', 'JB', 'BP', 'VS', 'JK', 'LO', 'NH'};

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
    '__event1_trials_precues0', '__event1_trials_precues1', '__event1_trials_precues2',...
    };

cond_suffix_targ = {...
    '__event2_trials_target0', '__event2_trials_target1', '__event2_trials_target2',...
    };

cond_suffix_move = {...
    '__event3_trials_movement0', '__event3_trials_movement1', '__event3_trials_movement2',...
    };

cond_suffix_ready = {...
    '__event4_trials_ready0', '__event4_trials_ready1', '__event4_trials_ready2',...
    };
% parameters unique to each subject:
sub_chs_to_average_hipp = {...
    {{'RH1', 'RH2'}, {'LH1', 'LH2'}},...
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


%% Hippocampus ROI for pre-cue epoch:

[z_mag_cue_hipp, z_diff_cue_hipp] = analyze_roi_erp_zscore(data_directory_output,...
    sub_prefix, z_file_prefix_precue_hipp, sub_ROI_chs_hipp, sub_chs_to_average_hipp);
save z_stats_cue_hipp2 z_mag_cue_hipp z_diff_cue_hipp
%% Hippocampus ROI for target epoch:

[z_mag_targ_hipp, z_diff_targ_hipp] = analyze_roi_erp_zscore(data_directory_output,...
    sub_prefix, z_file_prefix_target_hipp, sub_ROI_chs_hipp, sub_chs_to_average_hipp);
save z_stats_targ_hipp2 z_mag_targ_hipp z_diff_targ_hipp

%% Hippocampus ROI for movement epoch:

[z_mag_move_hipp, z_diff_move_hipp] = analyze_roi_erp_zscore(data_directory_output,...
    sub_prefix, z_file_prefix_movement_hipp, sub_ROI_chs_hipp, sub_chs_to_average_hipp);
save z_stats_move_hipp2 z_mag_move_hipp z_diff_move_hipp


%% Hippocampus ROI for ready epoch:
% [z_mag_ready_hipp, z_diff_ready_hipp] = analyze_roi_erp_zscore(data_directory_output,...
%     sub_prefix, z_file_prefix_ready_hipp, sub_ROI_chs_hipp, sub_chs_to_average_hipp);
% save z_stats_ready_hipp2 z_mag_ready_hipp z_diff_ready_hipp


%% Cortical ROI for pre-cue epoch:

[z_mag_cue_cort, z_diff_cue_cort] = analyze_roi_erp_zscore(data_directory_output,...
    sub_prefix, z_file_prefix_precue_cort, sub_ROI_chs_cort, sub_chs_to_average_cort);
save z_stats_cue_cort2 z_mag_cue_cort z_diff_cue_cort
%% Cortical ROI for target epoch:

[z_mag_targ_cort, z_diff_targ_cort] = analyze_roi_erp_zscore(data_directory_output,...
    sub_prefix, z_file_prefix_target_cort, sub_ROI_chs_cort, sub_chs_to_average_cort);
save z_stats_targ_cort2 z_mag_targ_cort z_diff_targ_cort

%% Cortical ROI for movement epoch:

[z_mag_targ_cort, z_diff_targ_cort] = analyze_roi_erp_zscore(data_directory_output,...
    sub_prefix, z_file_prefix_movement_cort, sub_ROI_chs_cort, sub_chs_to_average_cort);
save z_stats_move_cort2 z_mag_targ_cort z_diff_targ_cort


%% Cortical ROI for ready epoch:

% [z_mag_ready_cort, z_diff_ready_cort] = analyze_roi_erp_zscore(data_directory_output,...
%     sub_prefix, z_file_prefix_ready_cort, sub_ROI_chs_cort, sub_chs_to_average_cort);
% save z_stats_ready_cort2 z_mag_ready_cort z_diff_ready_cort