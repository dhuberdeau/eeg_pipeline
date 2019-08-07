function [s, varargout] = recode_main_func(behavior_files_in_ecog_files,...
    data_sets, rawcodes_sufix, output_prefix, intermediate_data_sufix, ...
    behavior_dir, files_ordered, home_dir, output_dir, seg_file_pre, seg_file)

recodes_sufix = 'recode.rcd';

output_condition = '-o eeglab'; % or eegad

% mapping showing how triggers should be re-defined based on trial type.
trig_type_recode = [...
    15 15 15 15 15 ...
    170 170 170 170 170 ...
    175 175 175 175 175 ...
    201 201 201 201 201 ...
    ;...
    0 1 2 3 4 ...
    0 1 2 3 4 ...
    0 1 2 3 4 ...
    0 1 2 3 4 ...
    ;...
    11 12 13 14 15  ...
    21 22 23 24 25 ...
    31 32 33 34 35 ...
    41 42 43 44 45 ...
    ]';
trig_set = unique(trig_type_recode(:,1));
type_set = unique(trig_type_recode(:,2));
conditional_triggers = [85 175]; %triggers that might not occure per trial
% because they are contingent on proper movement;

rt_set = cell(size(behavior_files_in_ecog_files));
for i_set = 1:length(behavior_files_in_ecog_files)
     % analyze behavioral data and get a table of reaction times, trial types,
    % and target directions (contained in rt_set as three diff. columns, respectively)
    rt_set{i_set} = analyze_behavior_milg_v2(behavior_dir, files_ordered(behavior_files_in_ecog_files{i_set}));
    
    % create a new event in each subject's pre-processed data file that
    % corresponds to the actual movement time as determined from analysis
    % of the behavioral data:
    insert_movement_event_trigger(home_dir,...
        [data_sets{i_set}, intermediate_data_sufix, '.set'],... % file to act on.
        rt_set{i_set}, output_dir);
    
    % get a list of the trigger events (raw codes) and the latency of those
    % events from the dataset:
    mipavg4([data_sets{i_set}, intermediate_data_sufix, '.set'], seg_file_pre,...
        ['-p ', output_dir, filesep, data_sets{i_set}], '-o raw_codes') ;
    
    
    % import the raw_codes file to extract the trigger event and latencies:
    all_codes = import_rawcode_file([output_dir, filesep, data_sets{i_set}, '_', rawcodes_sufix]);
    trig_code = all_codes.VarName1; %trigers are in "VarName1"
    trig_recode = nan(size(trig_code));
    
    % make sure the triggers found in raw_codes and the trials done in
    % behavioral session match. If not, will have to figure out what went
    % wrong, and discard the trials that are missing from either EEG data
    % or behavioral data. Most likely salvagable.
    assert(size(rt_set{i_set},1) == sum(trig_code == trig_set(1))...
        || size(rt_set{i_set},1) == sum(trig_code == trig_set(1)), 'triggers missing');
    
    % re-define trigger values based on trial type:
    try
        for i_trig = 1:length(trig_set)
            recode_set = rt_set{i_set}(:, 2);
            for i_type = 1:length(type_set)
                recode_set(recode_set == type_set(i_type)) = ...
                    trig_type_recode(trig_type_recode(:,1) == trig_set(i_trig) &...
                    trig_type_recode(:,2) == type_set(i_type), 3);
            end
            if ismember(trig_set(i_trig), conditional_triggers)
                recode_set(isnan(rt_set{i_set}(:, 1))) = nan; 
                trig_recode(trig_code == trig_set(i_trig)) = recode_set(~isnan(recode_set));
            else
                trig_recode(trig_code == trig_set(i_trig)) = recode_set;
            end
        end
    catch err___
        warning('error');
    end

    try
        % write out a file describing how to recode each trigger value.
        % This file should have 2 columns: the first is the original code,
        % the second is the value for that trigger to be reassigned. The
        % number of rows must be equal to the total number of triggers
        % contained in the file. If an original trigger value is to be not
        % re-assigned, make the second column for that trigger NaN.
        dlmwrite([output_dir, filesep, data_sets{i_set}, recodes_sufix],...
            [trig_code, trig_recode],...
            'delimiter', ' ');
    catch err_write
        warning('File not written out')
    end
end

% Read in the files corresponding to each pre-processed data set, combine
% them if their are multiple (up to 4), recode the triggers from the recode
% files, and save output specified as in output_condition (e.g. as an
% eeglab file)
switch length(data_sets)
    case 1
        mipavg4(...
            [data_sets{1}, intermediate_data_sufix, '.set'],... %specify the two eeg data files
            seg_file,... %specify segment control file 
            [data_sets{1}, recodes_sufix], ... %specify the two rcd files
                ['-p ', output_dir, filesep, output_prefix], output_condition);
            RT_total = rt_set{1};
    case 2
        mipavg4(...
            [data_sets{1}, intermediate_data_sufix, '.set'], [data_sets{2}, intermediate_data_sufix, '.set'],... %specify the two eeg data files
            seg_file,... %specify segment control file 
            [data_sets{1}, recodes_sufix], [data_sets{2}, recodes_sufix], ... %specify the two rcd files
                ['-p ', output_dir, filesep, output_prefix], output_condition);
            RT_total = [rt_set{1}; rt_set{2}];
    case 3
        mipavg4(...
            [data_sets{1}, intermediate_data_sufix '.set'], [data_sets{2}, intermediate_data_sufix, '.set'], [data_sets{3}, intermediate_data_sufix, '.set'],... %specify the two eeg data files
            seg_file,... %specify segment control file 
            [data_sets{1}, recodes_sufix], [data_sets{2}, recodes_sufix], [data_sets{3}, recodes_sufix], ... %specify the two rcd files
                ['-p ', output_dir, filesep, output_prefix], output_condition);
            RT_total = [rt_set{1}; rt_set{2}; rt_set{3}];
    case 4
        mipavg4(...
            [data_sets{1}, intermediate_data_sufix, '.set'], [data_sets{2}, intermediate_data_sufix, '.set'],...
            [data_sets{3}, intermediate_data_sufix, '.set'], [data_sets{4}, intermediate_data_sufix, '.set'],... %specify the two eeg data files
            seg_file,... %specify segment control file 
            [data_sets{1}, recodes_sufix], [data_sets{2}, recodes_sufix],...
            [data_sets{3}, recodes_sufix], [data_sets{4}, recodes_sufix], ... %specify the two rcd files
                ['-p ', output_dir, filesep, output_prefix], output_condition);
            RT_total = [rt_set{1}; rt_set{2}; rt_set{3}; rt_set{4}];
    otherwise
        error('Data set case unacknowledged')
end

% save out RT data
save([output_dir, filesep, output_prefix, '_RT'], 'RT_total');

% pass out errors if there are any.
s =  1;
if exist('err_write', 'var')
    varargout{1} = err_write;
else
    varargout{1}=[];
end