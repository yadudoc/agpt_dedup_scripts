#!/bin/bash

# Create clean start for indexing
rm -rf /dev/shm/combined
mkdir -p /dev/shm/combined/index


python -m deduplication --single \
       --name peS2o \
       --input /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/peS2o/minhashes/ \
       --minhash-dir /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/peS2o/minhashes/ \
       --skip-minhashing \
       --save-dir /dev/shm/combined/index \
       --output-file /dev/shm/combined/peS2o.dupes.csv \
       --sim-threshold 0.6 \
       --fp 5.555500503649536e-12 \
       --num 500000000

python -m deduplication --single \
       --name Arxiv_Dolma_v1.7 \
       --input /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/Arxiv_Dolma_v1.7/minhashes/ \
       --minhash-dir /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/Arxiv_Dolma_v1.7/minhashes/ \
       --skip-minhashing \
       --save-dir /dev/shm/combined/index \
       --output-file /dev/shm/combined/Arxiv_Dolma_v1.7.dupes.csv \
       --sim-threshold 0.6 \
       --fp 5.555500503649536e-12 \
       --num 500000000

# insert_test_arxiv
