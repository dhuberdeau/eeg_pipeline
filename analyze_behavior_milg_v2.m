function rt_trial_all = analyze_behavior_milg_v2(data_dir, data_files)
% rt_trial_all = analyze_ECoG_subj_behavior_milg_v1
%
% Compute the actual (behaviorally-determined) reaction times (rt's) for
% each trial of the experiment. Some might be indetermined (nan).
%
% output as an Nt x 3 matrix, where column 1 is the RTs, 2 is the trial
% type (1 = no-pre-cue, 2 = direct pre-cue, 3 = symbolic pre-cude)., 3 is
% the target number used (1,2,3,4).

rt_trial_all = nan(200, 3); %[trials: 200 ~ more than usually needed], [variables: rt, num trials, direction]
k_tr = [1, 1, 1, 1, 1];
k_tr_all = 1;
for i_file = 1:length(data_files)
    load([data_dir, filesep, data_files{i_file}]);

    for i_tr = 1:length(Data.Type)
         this_rt = ...
            compute_RT(Data.time_targ_disp(i_tr), ...
                Data.Kinematics{i_tr}(:, 1), ...
                Data.Kinematics{i_tr}(:, 2) - 1440/2, ... %offset pixels x
                Data.Kinematics{i_tr}(:, 3) - 900/2); %offset pixels y
        k_tr(Data.Type(i_tr) + 1) = k_tr(Data.Type(i_tr) + 1) + 1;

        rt_trial_all(k_tr_all, 1) = this_rt;
        rt_trial_all(k_tr_all, 2) = Data.Type(i_tr);
        rt_trial_all(k_tr_all, 3) = Data.Target(i_tr);
        k_tr_all = k_tr_all + 1;
    end
end
rt_trial_all = rt_trial_all(1:(k_tr_all - 1), :);

function rt = compute_RT(targ_time, kin_t, kin_x, kin_y)
% Compute the simple reaction time (rt) given the time of target appearance
% (targ_time) and the kinematics (kin_t, kin_x, kin_y)
%
% David Huberdeau

DISCARD = 4;%seconds
Ts = 1/60;
MVT_TH = 20; %pixels
MVT_EXT_MIN = 250;

% discard beginning of trial data:
kin_t_abrv = kin_t((DISCARD/Ts + 1):end);
kin_abrv = sqrt((kin_x((DISCARD/Ts + 1):end)).^2 + ...
    (kin_y((DISCARD/Ts + 1):end)).^2);

[mx_val, k_max] = max(kin_abrv);
try
    if mx_val > MVT_EXT_MIN
        % search backward for first time movement is below MVT_TH
        k_search = k_max;
        while kin_abrv(k_search) > MVT_TH
            k_search = k_search - 1;
        end
        t_mvt = kin_t_abrv(k_search);
    else
        warning('Movement magnitude not sufficient for trial.');
    end

    rt = t_mvt - targ_time;
    
    if rt < 0
        rt = nan;
    end
catch
    warning('Movement time search failed.')
    rt = nan;
end