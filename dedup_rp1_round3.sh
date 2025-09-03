#!/bin/bash

#PBS -S /bin/bash
#PBS -N Argonne_TPC_DEDUP
#PBS -m n
#PBS -l walltime=1:00:00
#PBS -l select=1:ncpus=32:ngpus=4
#PBS -o /eagle/argonne_tpc/yadunand/rp1_index.submit.stdout
#PBS -e /eagle/argonne_tpc/yadunand/rp1_index.submit.stderr
#PBS -l filesystems=home:grand:eagle
#PBS -A argonne_tpc
#PBS -q debug
set -e

source /home/yadunand/setup_agpt_env_3.sh


datasources=(
    /lus/eagle/projects/argonne_tpc/TextCollections/CoreParsed
)

minhashdir=/lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/CORE/minhashes

OUTPUT_DIR=/lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3
mkdir -p $OUTPUT_DIR

for datasource in ${datasources[@]}
do

    echo "Datasource : $datasource"
    # sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
    sourcename="CORE"
    
    if [ ! -d $OUTPUT_DIR/$sourcename/index ]
    then
        echo "$datasource is not yet processed. Computing index"
    else
        echo "$output_file is present. Skipping dedup"
	continue
    fi
    
    
    rm -rf /dev/shm/index
    mkdir -p /dev/shm/index/$sourcename
    mkdir -p /dev/shm/index/$sourcename/index

    start=$(date)
    python -m deduplication \
	   --single \
	   --name $sourcename \
	   --input $datasource \
	   --minhash-dir $minhashdir \
	   --save-dir /dev/shm/index/$sourcename/index \
	   --output-file /dev/shm/index/$sourcename/$sourcename.dupes.csv \
	   --sim-threshold 0.6 \
	   --fp 5.555500503649536e-12 \
	   --skip-minhashing \
	   --num $(( 5 * 10**8 ))
    echo "Started at $start; Finished at $(date)"
    ls /dev/shm/index
    
    cp -R /dev/shm/index/$sourcename $OUTPUT_DIR/
done
