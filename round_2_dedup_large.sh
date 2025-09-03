#!/bin/bash

set -e
source /home/yadunand/setup_agpt_env_3.sh

datasource=$1

OUTPUT_DIR=/dev/shm/index/



echo "Datasource : $datasource"
sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
echo "Sourcename : $sourcename"
    
rm -rf /dev/shm/index

mkdir -p /dev/shm/index/$sourcename

if [ ! -d $OUTPUT_DIR/$sourcename/index ]
then
    echo "$OUTPUT_DIR/$sourcename/index exists, copying to /dev/shm"
    cp -R $OUTPUT_DIR/$sourcename/index /dev/shm/index/$sourcename/index
    mkdir -p /dev/shm/index/$sourcename/index
else
    echo "Creating index from scratch"
    mkdir -p /dev/shm/index/$sourcename/index
    mkdir -p /dev/shm/index/$sourcename/index
fi

python -m deduplication \
       --single \
       --name $sourcename \
       --input $datasource \
       --minhash-dir /dev/shm/index/$sourcename/minhashes \
       --save-dir /dev/shm/index/$sourcename/index \
       --output-file /dev/shm/index/$sourcename/$sourcename.dupes.csv \
       --sim-threshold 0.6 \
       --fp 5.555500503649536e-12 \
       --num $(( 5 * 10**8 ))

ls /dev/shm/index
    
mv/dev/shm/index/$sourcename/index $OUTPUT_DIR/$sourcename/index
cp /dev/shm/index/$sourcename/minhashes/* $OUTPUT_DIR/$sourcename/minhashes
