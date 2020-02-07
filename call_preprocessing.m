function call_preprocessing(input_dir, input_file, output_dir, output_file)

input_parameters.filter_cutoff = 256;
input_parameters.downsample_rate = 512;
input_parameters.channels_to_remove = {};
output_prefs.output_dir =  output_dir;
output_prefs.output_file = output_file;
output_prefs.files_to_save = {'downsamp'}; %only save trigger and final data structure

fieldtrip_preprocessing_func(input_dir, input_file, input_parameters, output_prefs)
