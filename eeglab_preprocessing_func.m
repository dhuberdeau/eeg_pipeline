function eeglab_preprocessing_func(raw_data_dir, data_file, input_parameters, output_prefs)
%
%
% function = eeglabhist_func(data_file)
%
% First analysis stage for EEG data.
%
% Steps:
%   - load data
%   - filter data (125hz)
%   - downsample data (512hz)
%   - remove baseline
%   - swap trigger channels
%   - remove empty channels
%   - Select events from TRIG channel
%   - save at each step if specified to do so.
% EEGLAB history file generated on the 29-Jan-2019
% ------------------------------------------------


LOW_PASS_FILT_CUTOFF_FRQ = input_parameters.filter_cutoff;
RESAMPLE_RATE = input_parameters.downsample_rate;
channels_to_remove = input_parameters.channels_to_remove;

rm_channels = ~isempty(channels_to_remove);

EEG.etc.eeglabvers = '14.1.1'; % this tracks which version of EEGLAB is being used, you may ignore it

% load raw data file
EEG = pop_biosig([raw_data_dir, filesep, data_file, '.edf'], 'importevent','off');
EEG.setname=data_file;
EEG = eeg_checkset( EEG );
if ismember('raw', output_prefs.files_to_save)
    if ~exist([data_file, '_raw.set'], 'file')
        EEG = pop_saveset(EEG, 'filename', [data_file, '_raw.set'], 'filepath', '/home/david/');
    end
end

% filter data
EEG = pop_eegfiltnew(EEG, [],LOW_PASS_FILT_CUTOFF_FRQ,434,0,[],0);
EEG.setname=[data_file, '_filt'];
%EEG = pop_loadset('filename',[EEG.setname, '.set'],'filepath','/home/david/');
EEG = eeg_checkset( EEG );
if ismember('filt', output_prefs.files_to_save)
    if ~exist([data_file, '_filt.set'], 'file')
        EEG = pop_saveset( EEG, 'filename', [data_file, '_filt.set'], 'filepath', '/home/david/');
    end
end
length_of_raw_data = size(EEG.data,2);

% resample data
EEG = pop_resample( EEG, RESAMPLE_RATE);
EEG.setname=[data_file, '_512hz'];
EEG = eeg_checkset( EEG );
if ismember('downsamp', output_prefs.files_to_save)
    if ~exist([data_file, '_512hz.set'], 'file')
        EEG = pop_saveset( EEG, 'filename', [data_file, '_512hz.set'],'filepath','/home/david/');
    end
end

% remove baseline 
EEG = pop_rmbase(EEG, []);
EEG = eeg_checkset( EEG );
if ismember('baseline', output_prefs.files_to_save)
    if ~exist([data_file, '_baseline.set'], 'file')
        EEG = pop_saveset( EEG, 'filename', [data_file, '_baseline.set'], 'filepath', '/home/david/');
    end
end
%problematic channels (optional: view channels)
if rm_channels == 1
    EEG = pop_select( EEG,'nochannel',channels_to_remove);
end
EEG.setname=[data_file, '_rmch_512'];
EEG = eeg_checkset( EEG );
if ismember('rm_ch', output_prefs.files_to_save)
    if ~exist([data_file, '_rmch_512.set'], 'file')
        EEG = pop_saveset( EEG, 'filename', [data_file, '_rmch_512.set'],'filepath','/home/david/');
    end
end

% replace trigger channel
%[hdr, report] = edfread('/data/david/DO_d534.edf');
trigger_file_name = ['trigger_', data_file, '.mat'];
if exist(trigger_file_name, 'file')
    load(trigger_file_name)
else
    [hdr, record] = edfread(['/data/david/', data_file, '.edf']);
    trigger = record(strcmp(hdr.label, 'TRIG'), :);
    trigger_set = unique(trigger);
    if sum((trigger_set > 0) > 0)
        % trigger is correct sign
    else
        trigger = -trigger;
        trigger_set = unique(trigger);
        if sum((trigger_set > 0) > 0)
            % trigger is now the correct sign
        else
            % something is wrong with this trigger
            error('Trigger not properly found');
        end
    end
end
inds = 1:size(EEG.data,1);
ch_labels = cell(1, length(inds));
for i_ch = 1:length(inds)
    ch_labels{i_ch} = EEG.chanlocs(i_ch).labels;
end
trig_ch = inds(strcmp(ch_labels, 'TRIG'));
EEG = replace_trigger_channel(EEG, trigger, trig_ch, length_of_raw_data);
EEG = eeg_checkset( EEG );
if ismember('rm_ch', output_prefs.files_to_save)
    if ~exist([data_file, '_rmch_512.set'], 'file')
        EEG = pop_saveset( EEG, 'filename', [data_file, '_rmch_512.set'], 'filepath','/home/david/');
    end
end

EEG = pop_chanevent(EEG, trig_ch,'edge','leading','edgelen',1,'delchan','off');
EEG = eeg_checkset( EEG );
if ~exist([data_file, '_events.set'], 'file')
    EEG = pop_saveset( EEG, 'filename', [data_file, '_events.set'],'filepath','/home/david/');
end
