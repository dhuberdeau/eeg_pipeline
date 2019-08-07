% EEGLAB history file generated on the 26-Mar-2019
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','LL__event1_trials_precues0.set','filepath','/home/david/sandbox_4/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'freqs', [[5 30]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'alpha',0.01, 'freqs', [[5 30]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
EEG = pop_loadset('filename','LL__event1_trials_precues2.set','filepath','/home/david/sandbox_4/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'freqs', [[5 30]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'alpha',0.01, 'freqs', [[5 30]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'freqs', [[5 100]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'alpha',0.01, 'freqs', [[5 100]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'retrieve',1,'study',0); 
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'freqs', [[5 100]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 31, [-1000  2000], [3         0.5] , 'baseline',[0], 'alpha',.01, 'freqs', [[5 100]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);
eeglab redraw;


%% get TF decomposition without plotting:
[H, ~, ~, T, F] = pop_newtimef( EEG, 1, 31, [-1000 2000], [3 0.5] , 'baseline',[0], 'freqs', [[5 30]], 'plotitc' , 'off', 'plotphase', 'off', 'padratio', 1);