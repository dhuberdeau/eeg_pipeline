#!/usr/bin/env bash
# Run ft_load

#SBATCH --output=ft_load-%j.out
#SBATCH -p short
#SBATCH -t 300
#SBATCH -c 4
#SBATCH --mem-per-cpu 25000

# Load modules
module load MATLAB/2018b

# Go to directory
cd /gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/AnalysisScripts/sandbox_fieldtrip

# Run script
matlab -nodesktop -r "addpath(pwd); exceptions_post_processing; exit"
