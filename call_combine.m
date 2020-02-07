function call_combine(input_dir, input_files, output_dir, output_file, input_parameters)

% these are now defined above and passed through:
% input_parameters.intended_triggers = 14;
% input_parameters.actual_triggers = 14;
% input_parameters.channels_to_remove = {};
output_prefs.output_dir =  output_dir;
output_prefs.output_file = output_file;
output_prefs.files_to_save = {'epoch'};

fieldtrip_combine_sessions(input_dir, input_files, input_parameters, output_prefs)
