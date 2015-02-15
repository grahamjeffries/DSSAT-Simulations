#!/bin/bash
# parallel job using 16 processors. and runs for 4 hours (max)
#SBATCH -N 1   # node count
#SBATCH --ntasks-per-node=12
#SBATCH -t 12:00:00
# sends mail when process begins, and 
# when it ends. Make sure you define your email 
# SBATCH --mail-type=begin
# SBATCH --mail-type=end
# SBATCH --mail-user=johank@princeton.edu

# Load openmpi environment
R CMD BATCH inputScript.R
