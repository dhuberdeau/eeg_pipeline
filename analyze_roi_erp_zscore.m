function [z_gmax, diff_gmax] = analyze_roi_erp_zscore(data_dir, sub_prefix, ...
    data_file_prefix, sub_chs_analysis, sub_chs_to_average)
% script to plot each subject's ROI's mean erp and difference erp.
% David Huberdeau

% data_dir = '/home/david/group';
target_files_prefix = data_file_prefix; %which file to look for ("target"),
% not to be confused with the target event.

N_SUBS = length(sub_prefix);

% the channels that should be included in the analysis:
% sub_chs_analysis = {{'LH2', 'LH3', 'RH1', 'RH2', 'RH3'},...
%     {'FF1', 'FF2', 'EE1', 'EE2', 'EE3', 'DD1', 'DD2', 'DD3'},...
%     {'SS1', 'SS2', 'II1', 'II2'},...
%     {'MM1', 'MM2', 'MM3', 'MM4', 'KK1', 'KK2', 'KK3', 'KK4',...
%     'KK5', 'L5', 'L6', 'L7', 'L8', 'I3', 'I4', 'I5', 'I6'},...
%     {'EE1', 'EE2', 'FF1', 'FF2'},...
%     {'HH1', 'HH2', 'HH3', 'HH4', 'HH5', 'KK1', 'KK2'},...
%     {'KK1', 'KK2', 'MM1', 'MM2', 'MM3', 'OO1', 'OO2'},...
%     {'DD1', 'DD2', 'DD3'},...
%     };


% sub_chs_to_average = {{{'RH1', 'RH2'}, {'LH1', 'LH2'}},...
%     {{'II1', 'II2', 'II3'}, {'HH1', 'HH2'}},...
%     {{'SS1', 'SS2'}, {'II1', 'II2'}},...
%     {{'MM1', 'MM2', 'MM3', 'MM4'}},...
%     {{'FF1', 'FF2'}, {'EE1'}},...
%     {{'HH1', 'HH2', 'HH3', 'HH4', 'HH5'}, {'KK1', 'KK2'}},...
%     {{'MM1', 'MM2', 'MM3'}, {'OO1', 'OO2'}},...
%     {{'DD1', 'DD2', 'DD3'}}};

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

max_n_ch = 0;
for i_sub = 1:N_SUBS
    max_n_ch = max([max_n_ch, length(sub_chs_to_average{i_sub})]);
end

%%
fig_position = [0 500 1400 500];

z_max = nan(N_SUBS, max_n_ch, 3);
lat_max = nan(N_SUBS, max_n_ch, 3);
channel_max = cell(1, N_SUBS);
z_gmax = nan(N_SUBS, 3);
lat_gmax = nan(N_SUBS, 3);

% target_type = 3; % 1 - no cue, 2 - direct cue, 3 - symbolic cue
MAX_SIGNAL_TIME = 1;
ZSCORE_MAX_TH = 6;

for i_sub = 1:N_SUBS
    load([data_dir, filesep, target_files_prefix, num2str(i_sub), '.mat']);
    for i_elec = 1:length(sub_chs_to_average{i_sub})
        sub_elec_ROI_chs = sub_chs_to_average{i_sub}{i_elec};
        possible_channel_inds = 1:length(sub_elec_ROI_chs);
        desired_channel_inds = possible_channel_inds(ismember(sub_chs_to_average{i_sub}{i_elec}, sub_chs_analysis{i_sub}));
        channel_inds = 1:size(zscore_means_out,2);
        valid_channel_inds = channel_inds(~isnan(zscore_means_out(1,:,1)));
%         for i_ch = intersect(valid_channel_inds, desired_channel_inds)
        elec_chs = intersect(valid_channel_inds, desired_channel_inds);
            try
                for i_type = 1:size(zscore_times_out, 3)
                    time_window = zscore_times_out(:, elec_chs(1), i_type) > 0 & ...
                        zscore_times_out(:, elec_chs(1), i_type) < MAX_SIGNAL_TIME;
%                     zscore_elec_ = mean(abs(zscore_means_out(time_window, elec_chs, i_type)), 2);
%                     [z_max(i_sub, i_elec, i_type), lat_max(i_sub, i_elec, i_type)] = max(zscore_elec_);
                    zscore_elec_ = reshape(max(zscore_means_out(time_window, elec_chs, i_type), [], 1), length(elec_chs), 1);
                    z_max(i_sub, i_elec, i_type) = nanmean(zscore_elec_, 1);
                end
            catch err
                warning(['error occured on line ', num2str(err(1).stack.line)]);
            end
    end
end

%remove outliers (which might be included in they were part of the channel
%response for a condition that was not target_type condition).
% z_gmax(z_gmax > ZSCORE_MAX_TH) = nan;

%% plot the zscore bars:
z_gmax = reshape(nanmean(z_max,2), size(z_max,1), size(z_max,3)); % average together the 
% z_gmax = reshape(z_max(:,1,:), size(z_max,1), size(z_max,3));
% z_gmax = reshape(z_max(:,2,:), size(z_max,1), size(z_max,3));
%%
type_colors = {'r', 'g', 'b'};
type_color_vect = [172 59 59; 85 170 85; 86 85 149]./255;
figure;
f1 = gcf;
subplot(1,2,1); hold on;
for i_type = 1:3
    bar(i_type, nanmean(z_gmax(:,i_type),1), type_colors{i_type});
end

mg = nanmean(z_gmax,1);
sg = sqrt(nanvar(z_gmax, [], 1)./N_SUBS);
errorbar(1:3, mg, sg, 'k.');

axis([0 4 0 ceil(max(mg+sg))]);


% plot the zscore diffs:
subplot(1,2,2); hold on;
diff_gmax = [z_gmax(:, 2) - z_gmax(:, 1), z_gmax(:, 3) - z_gmax(:, 1)];
for i_type = 1:2
    bar(i_type, nanmean(diff_gmax(:, i_type)), type_colors{i_type+1});
end
md = nanmean(diff_gmax, 1);
sd = sqrt(nanvar(diff_gmax, [], 1)./N_SUBS);
errorbar(1:2, md, sd, 'k.');
axis([0 4 floor(min(md - sd)) ceil(max(md + sd))]);
f1.Position = [42 857 264 197];

%% do stats:
[a_h,a_x,a_stat] = anova1(z_gmax);
[d_h,d_x,~, d_stat] = ttest(diff_gmax);

