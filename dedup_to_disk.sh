#!/bin/bash

set -e
source /home/yadunand/setup_agpt_env_3.sh

datasource=$1

OUTPUT_DIR=/lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2

echo "Datasource : $datasource"
sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
echo "Sourcename : $sourcename"
    
python -m deduplication \
       --single \
       --name $sourcename \
       --input $datasource \
       --minhash-dir $OUTPUT_DIR/$sourcename/minhashes \
       --save-dir $OUTPUT_DIR/$sourcename/index \
       --output-file /dev/shm/$sourcename/$sourcename.dupes.csv \
       --sim-threshold 0.6 \
       --fp 5.555500503649536e-12 \
       --num $(( 5 * 10**8 ))
    
cat /dev/shm/$sourcename/$sourcename.dupes.csv >> $OUTPUT_DIR/$sourcename/$sourcename.dupes.csv
