function [zscore_means_out, zscore_sds_out, zscore_times_out, varargout] = ...
    compute_mean_erp_zscore_all(input_dir, output_dir, cond_sufix, sub_prefix, ...
    output_sufix, sub_ROI_chs)
% function signals_out = view_hipp_erp_all
% 
% Function to gather all the Hippocampal (or MTL) ROI signals across 
% conditions for all patients.
%
% David Huberdeau, 03/02/2019

% for cortical ROIs:
% sub_ROI_chs = {...
%     {'RAI9', 'RAI10', 'RAI11', 'LAI9', 'LAI10', 'LAI11'},...
%     {'CC9', 'CC10', 'CC11', 'CC12'},...
%     {'NN5', 'NN6', 'LL1', 'LL2', 'LL3', 'LL4', 'LL5', 'LL6', 'LL7', 'LL8', 'LL9', 'LL10', 'BB1', 'BB2', 'BB3', 'BB4', 'BB5', 'BB6', 'BB7', 'BB8', 'BB9', 'BB10'},...
%     {'C1', 'C2', 'C3', 'C4', 'C5', 'C6'},...
%     {},...
%     {'O6', 'O7', 'O8'},...
%     {'G14', 'G19'},...
%     {'G38', 'G39', 'G40', 'G46', 'G47', 'G48', 'G54', 'G55', 'G56'},...
%     };

N_POINTS = 1537; % at 512hz sampling rate with a window of 3-sec.
MAX_N_TRIALS = 70;
MAX_N_CHS = 0;
N_TYPE = 3;
for i_sub = 1:length(sub_prefix)
    MAX_N_CHS = max([MAX_N_CHS, length(sub_ROI_chs{i_sub})]);
end

for i_sub = 1:length(sub_prefix)
    try
    sub_ch_list = sub_ROI_chs{i_sub};
    zscore_means_out = nan(floor(N_POINTS), MAX_N_CHS, N_TYPE);
    zscore_sds_out = nan(floor(N_POINTS), MAX_N_CHS, N_TYPE);
    zscore_times_out = nan(floor(N_POINTS), MAX_N_CHS, N_TYPE);
    zscore_raw_out = nan(floor(N_POINTS), MAX_N_TRIALS, MAX_N_CHS, N_TYPE);
    for i_ch = 1:length(sub_ch_list)
        for i_type = 1:length(cond_sufix)
            try
                EEG = pop_loadset('filename',[sub_prefix{i_sub}, cond_sufix{i_type}, '.set'],'filepath',input_dir);

                chlabels = cell(1, length(EEG.chanlocs));
                for k_ch = 1:size(EEG.data,1)
                    chlabels{k_ch} = EEG.chanlocs(k_ch).labels;
                end

                chinds = 1:size(EEG.data,1);
                H_CHS = chinds(strcmp(chlabels, sub_ch_list{i_ch}));

                time_of_trig = 0;

                signal_mat_ = reshape(EEG.data(H_CHS, :, :), ...
                    size(EEG.data, 2), size(EEG.data, 3));
                
                signal_mat = sgolayfilt(double(signal_mat_), 3, 25);

                tim = EEG.times;

                sig_offsets = mean(signal_mat(tim < time_of_trig, :), 1);
                sig_shifted = signal_mat - repmat(sig_offsets, size(signal_mat,1), 1);

                [~, mu, sigma] = zscore(sig_shifted(tim < time_of_trig, :), 0, 1);
                sig_zscore = (sig_shifted - mu)./sigma;

                zscore_means_out(:, i_ch, i_type) = nanmean(sig_zscore, 2);
                zscore_sds_out(:, i_ch, i_type) = sqrt(nanvar(sig_zscore, [], 2)./size(sig_zscore, 2));
                zscore_times_out(:, i_ch, i_type) = tim;
                zscore_raw_out(:, 1:size(sig_zscore, 2), i_ch, i_type) = sig_zscore;
            catch err
                err
            end
        end
    end
    save([output_dir, filesep, output_sufix, num2str(i_sub), '.mat'],...
        'zscore_means_out', 'zscore_sds_out', 'zscore_times_out');
%       save([output_dir, filesep, output_sufix, num2str(i_sub), '.mat'],...
%         'zscore_times_out', 'zscore_raw_out');
    catch
        warning('Subject failed: compute_mean_erp_zscore_all');
    end
end
if exist('err', 'var')
    varargout{1} = err;
else
    varargout{1} = [];
end