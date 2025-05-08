#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -c 64
#SBATCH -t 0-06:00                  # wall time (D-HH:MM)
#SBATCH -o test_covar.out

# Manually set system type: 0 = equilibrium, 1 = non-equilibrium
system_type=0

if [ "$system_type" -eq 0 ]; then
    run_dir="run-NPT_equil_300K"
elif [ "$system_type" -eq 1 ]; then
    run_dir="run-NPT_non_equil_300K"
else
    echo "Invalid input. Please enter 0 or 1."
    exit 1
fi

#take the average between the 10 sets of cross-correlation matrices
#next step depends on previous step being done
cd $run_dir/

/scratch/mheyden1/MadR2014/gen-modes/avgBinMatrixList.exe ../templates/average.inp


#this step needs previous step to complete
#diagonalize the average matrix to obtain one set of eigenvalues for each frequency
module load fftw-3.3.10-aocc-3.2.0
export OMP_NUM_THREADS=64
/scratch/mheyden1/MadR2014/gen-modes/eigen_omp.exe ave_output.mmat
