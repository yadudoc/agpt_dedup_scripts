#!/bin/bash

#PBS -S /bin/bash
#PBS -N Argonne_TPC_DEDUP
#PBS -m n
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=32:ngpus=4
#PBS -o /eagle/argonne_tpc/yadunand/$PBS_JOBNAME.stdout
#PBS -e /eagle/argonne_tpc/yadunand/$PBS_JOBNAME.stderr
#PBS -l filesystems=home:grand:eagle
#PBS -A argonne_tpc
#PBS -q preemptable

datasources=(
    "ASM"
)

for datasource in ${datasources[@]}
do
    echo "Datasource : $datasource"
    # sourcename=$(basename $(dirname $datasource) | sed 's/.pymupdf//' )
    sourcename=$datasource
    python -m deduplication --multi \
	   --name $sourcename \
	   --input $datasource \
	   --minhash-dir /lus/eagle/projects/argonne_tpc/yadunand/minhashes/$sourcename \
	   --save-dir /dev/shm/yadunand/LLM4CS/index/ \
	   --output-file /lus/eagle/projects/argonne_tpc/yadunand/testing/$sourcename.dupes.csv \
	   --num $(( 5 * 10**8 )) \
           --skip-insertion
    echo "Copying index to /lus/eagle/projects/argonne_tpc/yadunand/index.$sourcename"
    # cp -R /dev/shm/index /lus/eagle/projects/argonne_tpc/yadunand/index.$sourcename
done


