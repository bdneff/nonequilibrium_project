#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -c 16
#SBATCH -t 0-02:00

# Generate topology (amber force field)
gmx=gmx_plumed
protein=1ubq.pdb

files=(
1ubq.pdb
mdp_files/equi-equilibirum.mdp
mdp_files/em.mdp
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

#can skip this step if structure has been made for alternative simulation
#${gmx} pdb2gmx -f ${protein} -ignh -o complex.gro -p complex.top -define FLEXIBLE << STOP
#6
#1
#STOP

#${gmx} editconf -f complex.gro -box 8 8 8 -o box.gro >& editconf.out

# Solvate the protein
#${gmx} solvate -cp box.gro -cs -p complex.top -o solv.gro >& solvate.out

#${gmx} grompp -f ions.mdp -c solv.gro -p complex.top -o ions.tpr
#${gmx} genion -s ions.tpr -o ions.gro -p complex.top -pname NA -nname CL -conc 150 << STOP
#13
#STOP

# Run energy minimizatoin
mkdir em_nonequil
cd em_nonequil
${gmx} grompp -f ../mdp_files/em.mdp -c ../solv.gro -r ../solv.gro -p ../complex.top -o topol.tpr -maxwarn 1 >& grompp.out
${gmx} mdrun -v -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpo state.cpt >& mdrun.out
cd ..

# Run equilibration
mkdir equi-NPT_nonequil
cd equi-NPT_nonequil
${gmx} grompp -f ../mdp_files/equi-nonequil.mdp -c ../em_nonequil/confout.gro -r ../em_nonequil/confout.gro -p ../complex.top -o topol.tpr -maxwarn 3 >& grompp.out
#${gmx} mdrun -v -nb gpu -pme gpu -ntmpi 9 -ntomp 3 -npme 1 -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpo state.cpt >& mdrun.out
${gmx} mdrun -v -s topol.tpr -o traj.trr -e ener.edr -g md.log -c confout.gro -cpi -ntomp 16 -pin on -pme cpu -cpo state.cpt >& mdrun.out
cd ..
