% EEGLAB history file generated on the 03-Jul-2019
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','NH__event1_trials_precues2.set','filepath','/home/david/sandbox_4/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
EEG = pop_loadset('filename','DO__event1_trials_precues2.set','filepath','/home/david/sandbox_4/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
figure; pop_newcrossf( EEG, 1, 64, 2, [-1000  2000], [3         0.5] ,'type', 'phasecoher', 'title','Channel FF9-AA2 Phase Coherence','padratio', 1, 'plotphase', 'off');
EEG = eeg_checkset( EEG );
figure; pop_newcrossf( EEG, 1, 64, 68, [-1000  2000], [3         0.5] ,'type', 'phasecoher', 'title','Channel FF9-HH2 Phase Coherence','padratio', 1, 'plotphase', 'off');
eeglab redraw;
