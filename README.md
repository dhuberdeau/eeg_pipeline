# Analysis pipeline for intracranial electroencephalography (iEEG) data

*David Huberdeau*,
*Turk-Browne lab*,
*Yale University*,
*Dept. of Psychology*

## Introduction
This directory contains code for processing intracranial electroencephalography (iEEG) data from patients undergoing intracranial monitoring for intractable epilepsy.

The code was constructed to be as generalizable as possible and to handle data obtained from intracranial or conventional EEG signals.

The following processing steps were implemented and are described in further detail in the sections below.

* **Pre-Process**
  - Load raw EEG data files
  - Filter and downsample EEG
  - Identify trigger events
  - Combine EEG files
  - Segment EEG into epochs
  - Behavior analysis
  - Align behavior and EEG data
* **Anatomical Localization**
* **Compute Features**
  - Compute ERP waveform
  - Compute Time-Frequency (TF) transform
  - Compute ERP Features
  - Compute TF Features
- **Statistical Analysis**
  - Statistics on activation estimates for each event
    - On channels in ROIs
    - On channels identified through activation
  - 
- **Advanced Analysis**
  - Pattern Similarity Analysis
  - Coherence Analysis
  - Encoding Models
  - Classification
  - Searchlight analyses

## Pre-process

Pre-processing is the first step to analyzing EEG data. The steps are:
- **Load raw EEG data files**: files are collected as .edf and need to be converted to a workable format (e.g. as matlab variables)
- **Filter and downsample EEG**: Filtering the data at a frequency that is less that half the desired down-sampled rate will prevent ailising once the data is downsampled.
- **Identify trigger events**: Triggers are used to align EEG to important or experimentally-relevant moments in time.
- **Combine EEG files**: The EEG data from an entire experiment can be quite large (e.g. >4GB), and consequently, experiments often need to be split into multiple files; these files ultimately need to be concatenated again once the data is loaded and downsampled.
- **Segment EEG into epochs**: The times around triggers that are to be included for further analysis need to be specified, along with what times, if any, will serve as the baseline to align signals to.
- **Artifact rejection**: Artifacts can contaminate EEG data and need to be identified and removed. A simple method is to remove signal that is an outlier (> 6 standard deviations) compared to the global signal statistics.
- **Behavior analysis**: The behavior needs to be analyzed, which may inlcude identifing bad trials and measuring relevant dependent variables.
- **Align behavior and EEG data**: Finally, EEG data epochs and behavioral variables/responses need to be aligned. This could include removing epochs from the EEG record that correspond to bad trials, or removing trials from the record that have EEG artifacts in them.

​

### Main function(s)

Function |  Description
---|---
*load_data_sets.m* | **Input**
  | raw_eeg_file_1.edf
  | ...
  | raw_eeg_file_n.edf
  | raw_behavior_1.m
  | ...
  | raw_behavior_m.m
  | **Parameters**
  | recode_segmentation_file_type1.sgc
  | ...
  | recode_segmentation_file_typeT.sgc
  | filter properties
  | downsample properties
  | Epoch properties
  | Channels to remove
  | Mapping of behavioral data files to EEG data files
  | **Output**
  | QA structure: Number of removed trials per channel
  | [SUB_LABEL]_[EVENT_TYPE].m (Time x N_trials x N_channels)
  | [SUB_LABEL]_behavior.m (N_trials x N_variables)


*Inputs to* `load_data_sets` *and parameter values are specified in a JSON file, which is passed to the function.*

*Outputs from* `load_data_sets` *inlude a Quality Assurance (QA) structure that lists the number of trials removed from each channel on account of an artifact, a matrix of data with pre-processed EEG signal (time-points X number of trials X number of channels), and a matrix of behavioral variables (number of trials X number of variables).*

The `load_data_set` function loads the EEG data and behavioral data, filters and downsamples the EEG signals, and aligns the behavioral and EEG data by trials. The resulting output is the pre-processed EEG signal for every trial in the experiment, aligned to each event specified in the input (e.g. aligned to the pre-cue, or aligned to movement onset). The advantage of structuring the data in this way is that additional analyses can be done on subsets of trials, such as dividing trials into various experimental conditions. Any trials with bad behavioral data are removed from both the behavioral data record and the EEG data record, and any trial with an EEG artificat on any channel is removed from both the behavioral data record and the EEG data record.

#### Looking ahead
Additional analyses can then include computing ERPs, computing the Time-Frequency decomposition, and estimating activation based on these. Higher-order analyses can be done as well, such as pattern similarity analysis, classification of behavioral variables from EEG features, testing inverted encoding models, or computing cross-coherence between different brain ROIs.

## Compute Features

The pre-processing step produced epoched EEG signals and behavioral responses. The next step is to compute features from those minimally-processed signals.

The following features are computed:
- Average ERPs
- Times at which ERP response is significant
- ERP supremum values: *scalar value per channel*
- Difference in ERP between experimental conditions
- Times at which ERP difference is significant
- Time-Frequency (TF) decompositions
- TF signals from frequency bands
- TF signal supremum values:
  - *As scalar value (the magnitude of the largest change)*
  - *As vector value (the magnitude of the largest change for every frequency band)*
- Difference in signal from frequency bands between experimental conditions
- Relevant behavioral features

## Statistical analyses

The computation of features produced vectors or scalars of feature values. The following analyses will be done on those feature values:
- Test for difference in features across experimental conditions.
  - *requires defining ROIs and identifying channels within them*
- Searchlight analysis across ROIs

## Advanced Analyses

The features computed above can also be subject to advanced methods such as:
- inverted encoding models: to reconstruct information representations from neural data
- classification: to attempt to extract information or test whether information is differentiated along a certain dimension within an ROI.
- Compute pattern similarity for vectors of activation with each ROI
- Do a Searchlight analysis using any of the above methods to find which brain areas are encoding information of a particular type or in a particular way.
