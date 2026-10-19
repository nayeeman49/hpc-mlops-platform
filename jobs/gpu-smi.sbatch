#!/bin/bash
#SBATCH --job-name=gpu-smi
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --output=/mnt/hpc/%x-%j.out

nvidia-smi
