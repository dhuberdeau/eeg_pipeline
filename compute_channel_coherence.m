%% coherence computation parameters:
time_window = [-1000 2000];
wavelet_cycles = [3, .5];
output_dims = [23, 200];

%% setup inputs and outputs:
subject_set_names = {...
    'P001',...
    'P002',...
    'P003',...
    'P004',...
    'P005',...
    'P006',...
    'P007',...
    'P008',...
    };

subject_channel_pairs_1 = {...
    {'LH1', 'LH2', 'LH3', 'RH1', 'RH2', 'RH3'},...
    {'II1', 'II2', 'II3', 'HH1', 'HH2'},...% for first surgical implantation (which is when the first session of data was collected
    {'SS1', 'SS2', 'II1', 'II2'},...
    {'MM1', 'MM2', 'MM3', 'MM4'},... % better localization of hippocampus
    {'EE1', 'FF1', 'FF2'},...
    {'HH1', 'HH2', 'HH3', 'HH4', 'HH5', 'KK1', 'KK2'},...
    {'KK1', 'KK2', 'MM1', 'MM2', 'MM3', 'OO1', 'OO2'},...
    {'DD1', 'DD2', 'DD3'},...
    };
subject_channel_pairs_2 = {...
    {'RAI9', 'RAI10', 'RAI11', 'LAI9', 'LAI10', 'LAI11'},...
    {'CC9', 'CC10', 'CC11', 'CC12'},...
    {'NN5', 'NN6', 'LL1', 'LL2', 'LL3', 'LL4', 'LL5', 'LL6', 'LL7', 'LL8', 'LL9', 'LL10', 'BB1', 'BB2', 'BB3', 'BB4', 'BB5', 'BB6', 'BB7', 'BB8', 'BB9', 'BB10'},...
    {'C1', 'C2', 'C3', 'C4', 'C5', 'C6'},...
    {},...
    {'O6', 'O7', 'O8'},...
    {'G14', 'G19'},...
    {'G38', 'G39', 'G40', 'G46', 'G47', 'G48', 'G54', 'G55', 'G56'},...
    };

subject_coherence_out_precue_type0 = cell(1,8);
subject_coherence_out_precue_type1 = cell(1,8);
subject_coherence_out_precue_type2 = cell(1,8);
subject_coherence_out_targ_type0 = cell(1,8);
subject_coherence_out_targ_type1 = cell(1,8);
subject_coherence_out_targ_type2 = cell(1,8);

for i_sub = 1:length(subject_coherence_out_precue_type0)
    subject_coherence_out_precue_type0{i_sub} = nan(output_dims(1), output_dims(2), ...
        length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}));
    subject_coherence_out_precue_type1{i_sub} = nan(output_dims(1), output_dims(2), ...
        length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}));
    subject_coherence_out_precue_type2{i_sub} = nan(output_dims(1), output_dims(2), ...
        length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}));
    
    subject_coherence_out_targ_type0{i_sub} = nan(output_dims(1), output_dims(2), ...
        length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}));
    subject_coherence_out_targ_type1{i_sub} = nan(output_dims(1), output_dims(2), ...
        length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}));
    subject_coherence_out_targ_type2{i_sub} = nan(output_dims(1), output_dims(2), ...
        length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}));
end

% setup EEGLAB:
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    
%% compute coherences among pairs of channels:
for i_sub = 1:length(subject_set_names)
    
    % Load in the data:
    EEG = pop_loadset('filename',[subject_set_names{i_sub}, '__event1_trials_precues2.set'],'filepath','/home/david/sandbox_4/');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    % Setup channels to compare:
    subject_ch_nums_1 = nan(1, length(subject_channel_pairs_1{i_sub}));
    subject_ch_nums_2 = nan(1, length(subject_channel_pairs_2{i_sub}));
    
    ch_inds = 1:length(EEG.chanlocs);
    ch_list = cell(1, length(EEG.chanlocs));
    for i_ch = 1:length(EEG.chanlocs)
        ch_list{i_ch} = EEG.chanlocs(i_ch).labels;
    end
    for i_ch = 1:length(subject_channel_pairs_1{i_sub})
        subject_ch_nums_1(i_ch) = ch_inds(strcmp(ch_list, subject_channel_pairs_1{i_sub}{i_ch}));
    end
    for i_ch = 1:length(subject_channel_pairs_2{i_sub})
        subject_ch_nums_2(i_ch) = ch_inds(strcmp(ch_list, subject_channel_pairs_2{i_sub}{i_ch}));
    end
    
    subject_ch_combo = nan(2, length(subject_ch_nums_1)*length(subject_ch_nums_2));
    i_ind = 1;
    for i_ch1 = 1:length(subject_ch_nums_1)
        for i_ch2 = 1:length(subject_ch_nums_2)
            subject_ch_combo(1, i_ind) = subject_ch_nums_1(i_ch1);
            subject_ch_combo(2, i_ind) = subject_ch_nums_2(i_ch2);
            i_ind = 1 + i_ind;
        end
    end
    
    % compare all combinations of channels:
    for i_comb = 1:(length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}))
        figure;
        [coh,mcoh,times,freqs] = pop_newcrossf(EEG, 1, subject_ch_combo(1,i_comb), subject_ch_combo(2,i_comb), ...
            [-1000, 2000], [3, 0.5],...
            'type', 'phasecoher', 'title','Channel FF9-AA2 Phase Coherence',...
            'padratio', 1, 'plotphase', 'off');
        close;

        subject_coherence_out_precue_type2{i_sub}(:,:,i_comb) = coh;  
    end
    
    % Load in the data of different trial type:
    EEG = pop_loadset('filename',[subject_set_names{i_sub}, '__event1_trials_precues1.set'],'filepath','/home/david/sandbox_4/');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    % compare all combinations of channels:
    for i_comb = 1:(length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}))
        figure;
        [coh,mcoh,times,freqs] = pop_newcrossf(EEG, 1, subject_ch_combo(1,i_comb), subject_ch_combo(2,i_comb), ...
            [-1000, 2000], [3, 0.5],...
            'type', 'phasecoher', 'title','Channel FF9-AA2 Phase Coherence',...
            'padratio', 1, 'plotphase', 'off');
        close;

        subject_coherence_out_precue_type1{i_sub}(:,:,i_comb) = coh;  
    end
    
    % Load in the data of different trial type:
    EEG = pop_loadset('filename',[subject_set_names{i_sub}, '__event1_trials_precues0.set'],'filepath','/home/david/sandbox_4/');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    
    % compare all combinations of channels:
    for i_comb = 1:(length(subject_channel_pairs_1{i_sub})*length(subject_channel_pairs_2{i_sub}))
        figure;
        [coh,mcoh,times,freqs] = pop_newcrossf(EEG, 1, subject_ch_combo(1,i_comb), subject_ch_combo(2,i_comb), ...
            [-1000, 2000], [3, 0.5],...
            'type', 'phasecoher', 'title','Channel FF9-AA2 Phase Coherence',...
            'padratio', 1, 'plotphase', 'off');
        close;

        subject_coherence_out_precue_type0{i_sub}(:,:,i_comb) = coh;  
    end
end