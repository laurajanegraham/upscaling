#!/bin/bash

#PBS -N sim_log
#PBS -l walltime=03:00:00,nodes=1:ppn=16
#PBS -t 1-499

cd $PBS_O_WORKDIR

module load R/3.5.1
module load geos/3.4.2
module load gdal/2.2.2
module load proj/4.9.3
module load gcc/6.1.0

Rscript psimulations.R
