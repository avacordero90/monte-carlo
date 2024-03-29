#!/bin/bash

trials=(100 1000 10000 100000 1000000)
threads=(1 2 4 8 16)
execution=()
cpus=$(grep -c ^processor /proc/cpuinfo)
echo -e "RESULTS:\nTrials, Threads, Speedup, Parallel Fraction" > ./results.csv

for tr in ${trials[@]}
do
	for th in ${threads[@]}
	do
		echo "*	NUMT:	$th"
		echo "*	NUMTRIALS:	$tr"

		g++ -DNUMT=$th  -DNUMTRIALS=$tr monte-carlo.cpp -o monte-carlo -lm -fopenmp
		execution=($(./monte-carlo) "${execution[@]}")
	done

	for th in $(seq 1 $((${#threads[@]}-1)))
	do
		speedup=$(echo "${execution[$th]} / ${execution[0]}" | bc -l)
		echo "*	${threads[$th]} to 1 thread Speedup:	$speedup"

		fp=$(echo "(${threads[$th]}.0 / (${threads[$th]}.0 - 1.0)) * (1.0 - (1.0 / $speedup))" | bc -l)
		echo -e "*	${threads[$th]} to 1 thread Parallel Fraction:	$fp\n"

		echo -e "$tr, ${threads[$th]}, $speedup, $fp" >> ./results.csv
	done
done

echo "*	Number of CPUs:	$cpus"
echo "*	System Load:	$(uptime)"

echo -e "\nNumber of CPUs:	$cpus" >> ./results.csv
echo -e "System Load:	$(uptime)" >> ./results.csv
