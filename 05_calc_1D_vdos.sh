#!/bin/bash

#direct the output here

mkdir 1D_vdos

cd 1D_vdos

mkdir output
mkdir input

cd ..

# Frequency range and step
start_freq=11
step=2
end_freq=35

# Parameters for the 2nd step
n_read=2500000
n_bins=500
n_modes=1000

# Loop over every 9th frequency
for ((freq=$start_freq; freq<=$end_freq; freq+=$step)); do
  # Define output file names
  proj_file="04_project_traj/output/proj_freq${freq}_mode1-${n_modes}_freq${freq}.dat"
  vdos_file="1D_vdos/output/freq${freq}_1d_vdos.dat"

  # Generate SLURM script
  slurm_file="1D_vdos/input/freq${freq}_1d_vdos.sh"
  cat <<EOL > $slurm_file
#!/bin/bash
#SBATCH -p lightwork
#SBATCH -N 1
#SBATCH -c 4
#SBATCH -t 0-02:00                  # wall time (D-HH:MM)
#SBATCH -o 2nd_${freq}.out

module load fftw-3.3.10-aocc-3.2.0

/scratch/mheyden1/MadR2014/gen-modes/proj2vdos.exe $proj_file $n_read $n_bins $n_modes $vdos_file
EOL

done

echo "2nd step scripts to get 1D VDOS generated for every ${step} frequencies from ${start_freq} to ${end_freq}."



# Iterate through all the generated 2nd step SLURM script files
for script in freq*_1d_vdos.sh; do
  echo "Submitting $script..."
  sbatch "$script"
done

