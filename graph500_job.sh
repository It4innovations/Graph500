#!/bin/bash

ml Graph500/3.0.0-intel-2018a
ml

echo "Parameters:"
echo "MPI procs: $G5_MPI_PROCS"
echo "Nodes: $G5_NODES"
echo "Problem size: $G5_PROBLEM_SIZE"

ulimit -c 0  #will not generate core dump files
export SKIP_VALIDATION=1
mpirun -n $G5_MPI_PROCS graph500_reference_bfs $G5_PROBLEM_SIZE 16
