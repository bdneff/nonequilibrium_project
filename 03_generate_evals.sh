#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 0-02:00

# Manually set system type: 0 = equilibrium, 1 = non-equilibrium
system_type=1

if [ "$system_type" -eq 0 ]; then
    run_dir="run-NPT_equil_300K"
elif [ "$system_type" -eq 1 ]; then
    run_dir="run-NPT_non_equil_300K"
else
    echo "Invalid input. Please enter 0 or 1."
    exit 1
fi


#split the trajectory up into 10 segments (diagonalization operation less memory intensive)
files=(
templates/coarseXXX.inp
templates/covarXXX.sh
templates/average.inp
templates/ave_eigen.sh
$run_dir/traj_pbc.trr
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

cd $run_dir

gmx_plumed convert-tpr -s topol.tpr -o topol_protein.tpr <<STOP
1
STOP

gmx_plumed trjconv -s topol_protein.tpr -f traj_pbc.trr -split 1000.0 -o traj_pbc_.trr <<STOP
0
STOP

#
i=0
while [ $i -lt 10 ]
do  cp ../templates/coarseXXX.inp coarse${i}.inp;
vi -c :%s/XXX/${i}/g -c :wq! coarse${i}.inp;
cp ../templates/covarXXX.sh covar${i}.sh;
vi -c :%s/XXX/${i}/g -c :wq! covar${i}.sh;
((i++))
done

#!/bin/bash
i=0
while [ $i -lt 10 ]
do sbatch covar${i}.sh;
((i++))
done

#take the average between the 10 sets of cross-correlation matrices
#next step depends on previous step being done

#/scratch/mheyden1/MadR2014/gen-modes/avgBinMatrixList.exe average.inp


#this step needs previous step to complete
#diagonalize the average matrix to obtain one set of eigenvalues for each frequency
#module load fftw-3.3.10-aocc-3.2.0
#export OMP_NUM_THREADS=64
#/scratch/mheyden1/MadR2014/gen-modes/eigen_omp.exe ave_output.mmat
