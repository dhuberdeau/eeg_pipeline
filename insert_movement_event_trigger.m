function s = insert_movement_event_trigger(eeg_file_path, eeg_file_set, rt_data, output_dir)
% function s = insert_movement_event_trigger(rt_data)
%
% Create a new trigger for each trial at the time of movement onset as
% determined by the behavioral data
%
% INPUT:
%   (1) eeg_file_set - a .set file that has the eeg data and event info.
%   (2) rt_data - a table of behavioral data, with reaction time (fist
%   column), trial type (second column), and target direction (third
%   column)
%
% OUTPUT:
%   Save the .set file with the same name (plus mvmt suffix) as a .set.
%
%
% David Huberdeau
% 03/30/2019


% note: EEG.event has fields type and latency; type is the trigger value,
% and latency is the offset from the beginning of the file where the
% trigger occurs, in SAMPLES. Note that this means that to get the
% millisecond offset, you'd have to multiply EEG.event(i).latency by
% EEG.srate.

% define some constants:
n_trig_types = 6;
target_trig = 170;
mvmt_trig = 175;

% load the 
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',eeg_file_set,'filepath',eeg_file_path);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );

trigger_value_list = nan(length(EEG.event), 1);
trigger_latency_list = nan(length(EEG.event), 1);
for i_event = 1:length(EEG.event)
    trigger_value_list(i_event) = EEG.event(i_event).type;
    trigger_latency_list(i_event) = EEG.event(i_event).latency;
end

n_trs = sum(trigger_value_list == 170);

new_trigger_value_list = nan(n_trs*(n_trig_types + 1), 1);
new_trigger_latency_list = nan(n_trs*(n_trig_types + 1), 1);
k_trigger = 1;
k_rt = 1;
for i_trig = 1:length(trigger_value_list)
    if trigger_value_list(i_trig) == target_trig
        % this trigger is the target trigger - assign the target trigger to
        % the new list, then insert an extra trigger value for the rt
        new_trigger_value_list(k_trigger) = trigger_value_list(i_trig);
        new_trigger_latency_list(k_trigger) = trigger_latency_list(i_trig);
        
        if ~isnan(rt_data(k_rt))
            % this trial's RT is valid
            k_trigger = k_trigger + 1;
            new_trigger_value_list(k_trigger) = mvmt_trig;
            new_trigger_latency_list(k_trigger) = ...
                trigger_latency_list(i_trig) + round(rt_data(k_rt, 1)*EEG.srate);
        end
        k_rt = k_rt + 1;
    else
        % this trigger is not the target trigger - assign whatever trigger
        % it is to the new list; do not insert any extra triggers.
        new_trigger_value_list(k_trigger) = trigger_value_list(i_trig);
        new_trigger_latency_list(k_trigger) = trigger_latency_list(i_trig);
    end
    k_trigger = k_trigger + 1;
end
% remove nan values from lists (which might happen if rt's were nan, etc)
new_trigger_latency_list = new_trigger_latency_list(~isnan(new_trigger_latency_list));
new_trigger_value_list = new_trigger_value_list(~isnan(new_trigger_value_list));

% sort triggers by value of the latency (I think it has to be sorted)
[new_trigger_latency_list, sort_inds_latency] =  sort(new_trigger_latency_list);
new_trigger_value_list = new_trigger_value_list(sort_inds_latency);

% sanity check that trigger value and latency came out same size.
assert(length(new_trigger_latency_list) == length(new_trigger_value_list), ...
    'Trigger lists must be the same size');

% re-assign events to include movement onset (computed from behavior)
event_temp = struct('latency', [], 'type', [], 'urevent', []);
event_temp_2 = struct('latency', [], 'type', []);

for i_event = 1:length(new_trigger_value_list)
    this_type = new_trigger_value_list(i_event);
    this_latency = new_trigger_latency_list(i_event);
    
    event_temp(i_event).latency = this_latency;
    event_temp(i_event).type = this_type;
    event_temp(i_event).urevent = i_event;
    
    event_temp_2(i_event).latency = this_latency;
    event_temp_2(i_event).type = this_type;
end


EEG.event = event_temp;
EEG.urevent = event_temp_2;

EEG = pop_saveset(EEG, 'filename', eeg_file_set, 'filepath', output_dir);
