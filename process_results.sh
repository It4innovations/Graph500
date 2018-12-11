#!/bin/bash

RESULTFILE="graph500_experiment_results.log"


#traverse all output files and generate one result file

echo "nodes, mpi_procs, problem_size, median_teps, total_time" > $RESULTFILE

TOTALTIME=0
for FILE in graph500_job.sh.o*
do
	PROCESSES=0
	NODES=0
	SIZE=0
	ISCORRECT=0
	MEDIANTEPS=0

	TESTS=0
	GRAPHTIME=0
	CONSTRUCTIONTIME=0
	BFSMEANTIME=0
	
	echo "#$FILE"
	
	LINES=$(wc -l < $FILE)
	if [ $LINES -eq 38 ]
	then
		ISCORRECT=1
	else
		ISCORRECT=0
	fi
	
	i=0
	while IFS= read line
	do
		if [ $i -eq 1 ]		#mpi procs
		then
			PROCESSES=$(echo "$line" | sed 's/[^0-9]*//g')
		fi
		
		if [ $i -eq 2 ]		#nodes
		then
			NODES=$(echo "$line" | sed 's/[^0-9]*//g')
		fi
		
		if [ $i -eq 3 ]		#problem size
		then
			SIZE=$(echo "$line" | sed 's/[^0-9]*//g')
		fi
		
		if [ $i -eq 6 ]		#number of tests
		then
			TESTS=$(echo "$line" | sed 's/[^0-9]*//g')
		fi
		
		if [ $i -eq 7 ]		#time of graph generation [float]
		then
			GRAPHTIME=$(echo "$line" | awk '{print $2}')	#can contain '!' character
			if [ "$GRAPHTIME" = "!" ]
			then
				GRAPHTIME=$(echo "$line" | awk '{print $3}')
			fi
		fi
		
		if [ $i -eq 9 ]		#time of construction [float]
		then
			CONSTRUCTIONTIME=$(echo "$line" | awk '{print $2}')	#can contain '!' character
			if [ "$CONSTRUCTIONTIME" = "!" ]
			then
				CONSTRUCTIONTIME=$(echo "$line" | awk '{print $3}')
			fi
		fi
		
		if [ $i -eq 15 ]		#test mean time [float]
		then
			BFSMEANTIME=$(echo "$line" | awk '{print $3}')	#can contain '!' character
			if [ "$BFSMEANTIME" = "!" ]
			then
				BFSMEANTIME=$(echo "$line" | awk '{print $4}')
			fi
		fi
		
		if [ $i -eq 26 ]	#median teps on index 26
		then
			MEDIANTEPS=$(echo "$line" | awk '{print $3}')	#can contain '!' character
			if [ "$MEDIANTEPS" = "!" ]
			then
				MEDIANTEPS=$(echo "$line" | awk '{print $4}')
			fi
		fi
		
		i=$((i+1))
	done < $FILE
	
	if [ $ISCORRECT -eq 1 ]
	then
		TIME=$(echo "$GRAPHTIME+$CONSTRUCTIONTIME+$TESTS*$BFSMEANTIME" | bc -l)
		TOTALTIME=$(echo "$TOTALTIME+$TIME" | bc -l)
		echo "$NODES; $PROCESSES; $SIZE; $MEDIANTEPS; $TIME" | tee -a $RESULTFILE
	else
		echo "$NODES; $PROCESSES; $SIZE; ERROR; ERROR" | tee -a $RESULTFILE
	fi
done
echo $TOTALTIME
