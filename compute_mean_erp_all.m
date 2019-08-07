function [signal_means_out, signal_sds_out, varargout] = ...
    compute_mean_erp_all(input_dir, output_dir, cond_sufix, sub_prefix, ...
    output_prefix, sub_ROI_chs)
% function signals_out = view_hipp_erp_all
% 
% Function to gather all the Hippocampal (or MTL) ROI signals across 
% conditions for all patients.
%
% David Huberdeau, 03/02/2019

N_POINTS = 1537; % at 512hz sampling rate with a window of 3-sec.
MAX_N_CHS = 0;
N_TYPE = 3;
for i_sub = 1:length(sub_prefix)
    MAX_N_CHS = max([MAX_N_CHS, length(sub_ROI_chs{i_sub})]);
end

for i_sub = 1:length(sub_prefix)
    try
    sub_ch_list = sub_ROI_chs{i_sub};
    signal_means_out = nan(N_POINTS, MAX_N_CHS, N_TYPE);
    signal_sds_out = nan(N_POINTS, MAX_N_CHS, N_TYPE);
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
                
                % low-pass filter raw erp: (using filter that retains
                % overall signal shape)
                signal_mat = sgolayfilt(double(signal_mat_), 3, 25);

                tim = EEG.times;

                sig_offsets = mean(signal_mat(tim < time_of_trig, :), 1);

                sig_shifted = signal_mat - repmat(sig_offsets, size(signal_mat,1), 1);
                sig_filt = sgolayfilt(double(sig_shifted), 3, 9);

                signal_means_out(:, i_ch, i_type) = nanmean(sig_filt, 2);
                signal_sds_out(:, i_ch, i_type) = sqrt(nanvar(sig_filt, [], 2)./size(sig_filt, 2));
                
            catch err
                warning(err.message)
            end
        end
    end
        save([output_dir, filesep, output_prefix, num2str(i_sub), '.mat'],...
            'signal_means_out', 'signal_sds_out');
    catch
        warning('Subject failed: compute_mean_erp_all')
    end
end
if exist('err', 'var')
    varargout{1} = err;
else
    varargout{1} = [];
end
