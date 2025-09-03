#!/bin/bash


INDEX=

cp -R $INDEX /dev/shm/index


python -m deduplication --single \
       --name acm \
       --input /lus/eagle/projects/LLM4CS/ \
       --minhash-dir /lus/eagle/projects/argonne_tpc/yadunand/data-sources-copy/minhashes/ACM --save-dir /dev/shm/index --output-file \
     /lus/eagle/projects/argonne_tpc/yadunand/duplicates_csv/acm_dupes.csv --num $(( 5 * 10**8 ))

