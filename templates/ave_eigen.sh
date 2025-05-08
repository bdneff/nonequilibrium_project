#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -c 64
#SBATCH -t 0-02:00                  # wall time (D-HH:MM)
#SBATCH -o ave_eigen.out

module load fftw-3.3.10-aocc-3.2.0
export OMP_NUM_THREADS=64
/scratch/mheyden1/MadR2014/gen-modes/eigen_omp.exe ave_output.mmat
