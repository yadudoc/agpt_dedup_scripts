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

set -e
source ~/setup_agpt_env.sh

cd /lus/eagle/projects/argonne_tpc/yadunand/

rm -Rf /dev/shm/index
mkdir /dev/shm/index

# TODO:2 Update this block to match the new jsonl dirs to index
datasources=(
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/IPCC.nougat/parsed_pdfs
    /lus/eagle/projects/argonne_tpc/yadunand/DOEcode/
)


for datasource in ${datasources[@]}
do
    echo "Datasource : $datasource"
    # sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
    sourcename=DOEcode
    mkdir -p /lus/eagle/projects/argonne_tpc/yadunand/index_individual/$sourcename/minhashes
    time python -m deduplication --multi \
	   --name $sourcename \
	   --input $datasource \
	   --minhash-dir /lus/eagle/projects/argonne_tpc/yadunand/index_individual/$sourcename/minhashes \
	   --save-dir /dev/shm/index \
	   --output-file /lus/eagle/projects/argonne_tpc/yadunand/index_individual/$sourcename/$sourcename.dupes.csv \
	   --num $(( 10 * 10**9 )) \

    du -sh /dev/shm/index
    echo "Copying index to /lus/eagle/projects/argonne_tpc/yadunand/index_individual/$sourcename/index"
    cp -R /dev/shm/index /lus/eagle/projects/argonne_tpc/yadunand/index_individual/$sourcename/index
    
done


