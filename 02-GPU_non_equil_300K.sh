#!/bin/bash
#SBATCH -p general
#SBATCH -G a100:1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH -t 2-00:00                  # wall time (D-HH:MM)
#SBATCH -o step-2_nonequil.out
#SBATCH --exclude=sc060
#SBATCH -J non_equil_sim_10ns
#SBATCH --mail-type=all
#SBATCH --mail-user=bdneff@asu.edu


#Run NPT Simulation for 10 ns
gmx=gmx_plumed

files=(
equi-NPT_nonequil/confout.gro
)

for file in ${files[@]}
do
if [ ! -f ${file} ]; then
echo "-could not find file ${file} in current directory"
echo "-you are either starting this in the wrong directory"
echo " or you missed a previous step"
echo "-exiting"
exit
fi
done

mkdir run-NPT_non_equil_300K/
cd run-NPT_non_equil_300K/

${gmx} grompp -f ../mdp_files/run-NPT-nonequil_300K.mdp -c ../equi-NPT_nonequil/confout.gro -p ../complex.top -o topol.tpr -maxwarn 1 >& grompp.out
${gmx} mdrun -v -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpi state.cpt -ntomp 16 -pin on -gpu_id 0 -nb gpu -cpo state.cpt >& mdrun.out
${gmx} trjconv -s topol.tpr -f traj.trr -pbc mol -o traj_pbc.trr << STOP >&trjconv.out
1
STOP
cd ..
