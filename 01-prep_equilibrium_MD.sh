#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -c 16
#SBATCH -t 0-01:00

# Generate topology (amber force field)
gmx=gmx_plumed
protein=1ubq.pdb

files=(
1ubq.pdb
equi-equilibirum.mdp
em.mdp
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

${gmx} pdb2gmx -f ${protein} -ignh -o complex.gro -p complex.top << STOP
6
7
STOP

${gmx} editconf -f complex.gro -box 8 8 8 -o box.gro >& editconf.out

#Solvate the protein
${gmx} solvate -cp box.gro -cs tip4p.gro -p complex.top -o solv.gro >& solvate.out

#${gmx} grompp -f ions.mdp -c solv.gro -p complex.top -o ions.tpr
#${gmx} genion -s ions.tpr -o ions.gro -p complex.top -pname NA -nname CL -conc 150 << STOP
#13
#STOP

# Run energy minimizatoin
mkdir em_equil
cd em_equil
${gmx} grompp -f ../em.mdp -c ../solv.gro -r ../solv.gro -p ../complex.top -o topol.tpr >& grompp.out
${gmx} mdrun -v -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpo state.cpt >& mdrun.out
cd ..

# Run equilibration
mkdir equi-NPT_equilibrium
cd equi-NPT_equilibrium

${gmx} grompp -f ../equi-equilibirum.mdp -c ../em_equil/confout.gro -r ../em_equil/confout.gro -p ../complex.top -o topol.tpr -maxwarn 3 >& grompp.out
#this is mdrrun comman for GPUs
#${gmx} mdrun -v -nb gpu -pme gpu -ntmpi 9 -ntomp 3 -npme 1 -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpo state.cpt >& mdrun.out
#this is mdrun command for CPUs its
${gmx} mdrun -v -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpi -ntomp 16 -pin on -pme cpu -cpo state.cpt >& mdrun.out
cd ..
