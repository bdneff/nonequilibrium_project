#!/bin/bash

mkdir 04_project_traj
cd 04_project_traj

mkdir inputs
mkdir outputs

#specify the range of frequencies from which we will extract eigenvectors to project velocities onto
#frequency index
start_freq=101
step=1
end_freq=300

# Loop over every 10th frequency
for ((freq=$start_freq; freq<=$end_freq; freq+=$step)); do
  # Generate SLURM script
  slurm_file="input/int_freqs${freq}.sh"
  cat <<EOL > $slurm_file
#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH --mem 64G
#SBATCH -c 1
#SBATCH -t 1-00:00                  # wall time (D-HH:MM)

#SBATCH -o output/proj${freq}.out

module load fftw-3.3.10-aocc-3.2.0
/scratch/mheyden1/MadR2014/gen-modes/projTrjOnSelFreqModes.exe input/int_freqs${freq}.inp
EOL

  # Generate input file
  input_file="input/int_freqs${freq}.inp"
  cat <<EOL > $input_file
#fnTop
protein.mtop
#fnCrd
traj_pbc.trr
#fnVel (if format xyz,crd,dcd)
#fnJob
static.job
#nRead
2500000
#analysisInterval
1
#fnRef
../protein_ref.gro
#alignGrp
0
#analyzeGrp
0
#wrap
0
#fnEigVec
evec_ave_output.mmat
#freqSel
${freq}
#modeStart
1
#modeEnd
1000
#fnOut
output/freq${freq}
EOL

done

echo "Scripts and input files generated for every 10th frequency from ${start_freq} to ${end_freq}."

# Iterate through all the generated SLURM script files
for script in input/int_freqs*.sh; do
  echo "Submitting $script..."
  sbatch "$script"
done

echo "scripts submitted!"

cd ..
