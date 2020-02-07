%% setup parameters and file locations:

EXPERIMENT = 1; %options: 1 or 2

switch EXPERIMENT
    case 1
        subj_initials = {'LL_', 'DO_', 'JB_', 'BP_', 'VS_', 'JK_', 'LO_', 'NH_'}; %vma1
        subject_nums = [1,2,3,4,5,6,7,8]; %vma1
        electrode = {...
            {'LH1', 'LH2', 'LH3', 'RH1', 'RH2', 'RH3'},...
            {'II1', 'II2', 'II3', 'HH1', 'HH2'},...% for first surgical implantation (which is when the first session of data was collected
            {'SS1', 'SS2', 'II1', 'II2'},...
            {'MM1', 'MM2', 'MM3', 'MM4'},... % better localization of hippocampus
            {'EE1', 'FF1', 'FF2'},...
            {'HH1', 'HH2', 'HH3', 'HH4', 'HH5', 'KK1', 'KK2'},...
            {'KK1', 'KK2', 'MM1', 'MM2', 'MM3', 'OO1', 'OO2'},...
            {'DD1', 'DD2', 'DD3'},...
        }; %vma1
        rt_dataset = 'rt_set_vma1.mat';
    case 2
        subj_initials = {'DG_', 'CF_', 'CH_', 'WL_', 'DR_', 'DC_',...
            'PL_', 'RW_', 'MS_', 'DRJ'}; %vma2
        subject_nums = [1,2,3,4,5,6,7,8,9,10]; %vma2
        electrode = {{'MM1', 'MM2', 'MM3'},...
            {'LL1', 'LL2', 'LL3'},...
            {'RHC1', 'RHC2', 'LHC1', 'LHC2'},...
            {'HH1', 'HH2', 'HH3'},...
            {'RHc1', 'RHc2', 'LHc1', 'LHc2'},...
            {'RHC1', 'RHC2', 'LPES1', 'LPES2', 'LHC1', 'LHC2'},...
            {},...
            {'RHc1', 'RHc2', 'RHc3'},...
            {'MT4', 'MT5', 'MT6'},...
            {'RH1', 'RH2', 'RH3', 'LH1', 'LH2', 'LH3'}...
            }; %vma2
        rt_dataset = 'rt_set_short.mat';
    otherwise
        error('experiment not specified');
end

feature_name = '_erp_data';
label_name = 'labels';

valid_rts = [.2 .8];

load(rt_dataset);

%% plot feature across trials:
figure;
k_ind_subs = nan(1,length(subj_initials));
for i_sub = 1:length(subj_initials)
    try
    load([subj_initials{i_sub}, feature_name, '.mat']);
    load([subj_initials{i_sub}, label_name, '.mat']);
    
    labs = data.label;
    inds = 1:length(labs);
    k_ind = inds(strcmp(electrode{i_sub}{1}, labs));
    
    if isempty(k_ind)
        warning('Channel not found');
    else
        k_ind_subs(i_sub) = k_ind;
    end
    
    subplot(3,4,i_sub); hold on
    f0 = features(rt_set{i_sub}(:,2) == 0, k_ind);
    f1 = features(rt_set{i_sub}(:,2) == 1, k_ind);
    f2 = features(rt_set{i_sub}(:,2) == 2, k_ind);
    plot(f0, 'r.');
    plot(f1, 'g.');
    plot(f2, 'b.');
    catch
    end
end

%% plot feature as an average difference from no-cue:
figure;
feature_diff = nan(length(subj_initials), 2);
for i_sub = 1:length(subj_initials)
    try
        load([subj_initials{i_sub}, feature_name, '.mat']);
        load([subj_initials{i_sub}, label_name, '.mat']);
        sub_features_0 = nan(sum(rt_set{i_sub}(:,2) == 0), length(electrode{i_sub}));
        sub_features_1 = nan(sum(rt_set{i_sub}(:,2) == 1), length(electrode{i_sub}));
        sub_features_2 = nan(sum(rt_set{i_sub}(:,2) == 2), length(electrode{i_sub}));
        
        for i_ch = 1:length(electrode{i_sub})
            labs = data.label;
            inds = 1:length(labs);
            k_ind = inds(strcmp(electrode{i_sub}{i_ch}, labs));

            subplot(3,4,i_sub); hold on
            f0_ = features(rt_set{i_sub}(:,2) == 0, k_ind);
            f1_ = features(rt_set{i_sub}(:,2) == 1, k_ind);
            f2_ = features(rt_set{i_sub}(:,2) == 2, k_ind);
        
            sub_features_0(:, i_ch) = f0_;
            sub_features_1(:, i_ch) = f1_;
            sub_features_2(:, i_ch) = f2_;
            
        end
        f0 = sub_features_0;
        f1 = sub_features_1;
        f2 = sub_features_2;
%         f0 = nanmean(sub_features_0,2);
%         f1 = nanmean(sub_features_1,2);
%         f2 = nanmean(sub_features_2,2);
        
        bar(2, nanmean(abs(nanmean(f0,1) - nanmean(f1,1)),2), 'k');
        bar(3, nanmean(abs(nanmean(f0,1) - nanmean(f2,1)),2), 'k');
 
        errorbar(2, nanmean(abs(nanmean(f0,1) - nanmean(f1,1)),2), sqrt(nanmean(nanvar(f1))./length(f1)), 'k.');
        errorbar(3, nanmean(abs(nanmean(f0,1) - nanmean(f2,1)),2), sqrt(nanmean(nanvar(f2))./length(f2)), 'k.');

        feature_diff(i_sub, 1) = nanmean(abs(nanmean(f0,1) - nanmean(f1,1)),2);
        feature_diff(i_sub, 2) = nanmean(abs(nanmean(f0,1) - nanmean(f2,1)),2);

%         f0 = nanmean(sub_features_0,2);
%         f1 = nanmean(sub_features_1,2);
%         f2 = nanmean(sub_features_2,2);
%         
%         bar(2, abs(nanmean(f0) - nanmean(f1)), 'k');
%         bar(3, abs(nanmean(f0) - nanmean(f2)), 'k');
%  
%         errorbar(2, abs(nanmean(f0) - nanmean(f1)), sqrt(nanvar(f1)./length(f1)), 'k.');
%         errorbar(3, abs(nanmean(f0) - nanmean(f2)), sqrt(nanvar(f2)./length(f2)), 'k.');
% 
%         feature_diff(i_sub, 1) = abs(nanmean(f0) - nanmean(f1));
%         feature_diff(i_sub, 2) = abs(nanmean(f0) - nanmean(f2));
    catch
    end
end

[h,p,aa,ss] = ttest(diff(feature_diff, [], 2));

%% test correlation with RT:
rt_all = {[],[],[]};
ft_all = {[],[],[]};
for i_sub = 1:length(subj_initials)
    try
        load([subj_initials{i_sub}, feature_name, '.mat']);
        load([subj_initials{i_sub}, label_name, '.mat']);
        
        sub_features_0 = nan(sum(rt_set{i_sub}(:,2) == 0), length(electrode{i_sub}));
        sub_features_1 = nan(sum(rt_set{i_sub}(:,2) == 1), length(electrode{i_sub}));
        sub_features_2 = nan(sum(rt_set{i_sub}(:,2) == 2), length(electrode{i_sub}));
        
        for i_ch = 1:length(electrode{i_sub})
            labs = data.label;
            inds = 1:length(labs);
            k_ind = inds(strcmp(electrode{i_sub}{i_ch}, labs));

            subplot(3,4,i_sub); hold on
            f0_ = features(rt_set{i_sub}(:,2) == 0, k_ind);
            f1_ = features(rt_set{i_sub}(:,2) == 1, k_ind);
            f2_ = features(rt_set{i_sub}(:,2) == 2, k_ind);
        
            sub_features_0(:, i_ch) = f0_;
            sub_features_1(:, i_ch) = f1_;
            sub_features_2(:, i_ch) = f2_;
            
        end
        f0 = nanmean(sub_features_0,2);
        f1 = nanmean(sub_features_1,2);
        f2 = nanmean(sub_features_2,2);
        
        r0 = rt_set{i_sub}(rt_set{i_sub}(:,2) == 0, 1);
        r1 = rt_set{i_sub}(rt_set{i_sub}(:,2) == 1, 1);
        r2 = rt_set{i_sub}(rt_set{i_sub}(:,2) == 2, 1);
        
        ft_all{1} = cat(1, ft_all{1}, f0);
        ft_all{2} = cat(1, ft_all{2}, f1);
        ft_all{3} = cat(1, ft_all{3}, f2);
        
        rt_all{1} = cat(1, rt_all{1}, r0);
        rt_all{2} = cat(1, rt_all{2}, r1);
        rt_all{3} = cat(1, rt_all{3}, r2);
    
    catch err__
        warning(err__.message);
    end
end

%%

figure; 
lm_p_val = nan(1,3);
for i_type = 1:3
    rt_ = rt_all{i_type};
    rt_v = rt_(rt_ > valid_rts(1) & rt_ < valid_rts(2));
    
    ft_ = ft_all{i_type};
    ft_v = ft_(rt_ > valid_rts(1) & rt_ < valid_rts(2));
    
    subplot(1,3,i_type); hold on;
    plot(rt_v, ft_v, 'k.'); 
    
    lm_ = fitlm(rt_v, ft_v);
    lm_p_val(i_type) = lm_.Coefficients.pValue(2);
    
    plot(valid_rts, lm_.Coefficients.Estimate(1) + lm_.Coefficients.Estimate(2)*valid_rts, 'r-');
end