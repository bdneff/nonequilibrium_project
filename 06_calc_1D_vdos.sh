#!/bin/bash

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

#direct the output here

mv /scratch/bdneff/non-equil_project/DEPDIST/sample_setup_NEQ/$run_dir/project_traj/proj*freq*.dat /scratch/bdneff/non-equil_project/DEPDIST/sample_setup_NEQ/$run_dir/project_traj/output

mkdir $run_dir/1D_vdos

cd $run_dir/1D_vdos

mkdir output
mkdir input

cd ..
cd ..

# Frequency range and step
start_freq=1
step=1
end_freq=5

# Parameters for the 2nd step
n_read=2500000
n_bins=500
n_modes=1000

# Loop over every 9th frequency
for ((freq=$start_freq; freq<=$end_freq; freq+=$step)); do
  # Define output file names
  proj_file="$run_dir/project_traj/output/proj_freq${freq}_mode1-${n_modes}_freq${freq}.dat"
  vdos_file="$run_dir/1D_vdos/output/freq${freq}_1d_vdos.dat"

  # Generate SLURM script
  slurm_file="$run_dir/1D_vdos/input/freq${freq}_1d_vdos.sh"
  cat <<EOL > $slurm_file
#!/bin/bash
#SBATCH -p lightwork
#SBATCH -N 1
#SBATCH -c 4
#SBATCH -t 0-02:00                  # wall time (D-HH:MM)
#SBATCH -o $run_dir/1D_vdos/output/1D_VDOS_freq${freq}.out

module load fftw-3.3.10-aocc-3.2.0

/scratch/mheyden1/MadR2014/gen-modes/proj2vdos.exe $proj_file $n_read $n_bins $n_modes $vdos_file
EOL

done

echo "2nd step scripts to get 1D VDOS generated for every ${step} frequencies from ${start_freq} to ${end_freq}."



# Iterate through all the generated 2nd step SLURM script files
for script in $run_dir/1D_vdos/input/freq*_1d_vdos.sh; do
  echo "Submitting $script..."
  sbatch "$script"
done

#1DVDOS data will be in 1D_vdos_output
