#!/bin/bash
#SBATCH --job-name=gpu-torch
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --output=/mnt/hpc/%x-%j.out

python3 - << 'PY'
import torch
print("cuda", torch.cuda.is_available())
if torch.cuda.is_available():
    print(torch.cuda.get_device_name(0))
PY
