% main_pipeline.m
%
% Script to house the main pipeline for processing iEEG data from the
% VMA_recall experiment. 
%
% Step1: Load datasets and do pre-processing
%   load_data_sets.m
%
% Step2: compute features from ERP signals around trigger events
%   compute_all_means.m
%
% TODO:
% 
% RESPECTING ROIs:
% Step3: compute features from Time-Frequency analysis around trigger event
%   compute_tf_means.m
%
% Step4: Do multivariate analysis and break-down by target direction
%   mv_analysis.m
%
% USING WHOLE BRAIN:
% Step5: Do search for electrodes that show a difference among conditions
% for each epoch.
%   search_condition_differences.m
%
% Step6: Do search for electrode subset carrying significant information
% about reach direction at each epoch.
%   search_direction_selectivity.m
%
%
%
% Author: David Huberdeau
% Date: 03/23/2019
% NTB Lab.

%% script to load from raw datasets:
load_data_sets;

%% script to convert raw formats to ERP signals and features:
compute_all_means;

%% script to convert raw formats to Time-Frequency transform features:
