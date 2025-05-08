#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -c 48
#SBATCH -t 0-02:00                  # wall time (D-HH:MM)
#SBATCH -o test_covar.out

module load fftw-3.3.10-aocc-3.2.0
fresean covar -f coarseXXX.inp
