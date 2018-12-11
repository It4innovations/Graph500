#!/bin/bash

LOGFILE="graph500_experiment.log"
echo "mpi_procs, nodes, problem_size, jobid" > $LOGFILE
SIZE=0
PROCESSES=0

# use max number of processes (16) per node, because it must be power of 2
for n in $(seq 0 1 3)
do
	NODES=$((2**n)) #experiment on 1,2,4,8 nodes
	for s in $(seq 18 1 30)  #for problem size from 18 to 30
	do
		SIZE=$s
		PROCESSES=$((2**4*NODES)) #for 16,32,... process
		JOBID=$(qsub -q qexp -l select=${NODES}:mpiprocs=16 -v G5_MPI_PROCS=${PROCESSES},G5_PROBLEM_SIZE=${SIZE},G5_NODES=${NODES} graph500_job.sh)
		echo "$PROCESSES,$NODES,$SIZE,$JOBID" | tee -a $LOGFILE
	done
done
