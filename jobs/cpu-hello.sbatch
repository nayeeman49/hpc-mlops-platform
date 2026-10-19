#!/bin/bash
#SBATCH --job-name=cpu-hello
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=/mnt/hpc/%x-%j.out

echo "job ${SLURM_JOB_ID} on $(hostname)"
sleep 5
