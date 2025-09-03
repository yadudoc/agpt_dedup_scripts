#!/bin/bash
set -e

pending=(
    /lus/eagle/projects/argonne_tpc/TextCollections/peS2o/JSON_data/
)

datasources=(
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/Bioarxiv.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/Medrxiv.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/NIH_LitArch.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/OSTI.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/PMC-OA.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/TextCollections/RP1/arxiv
    #/lus/eagle/projects/LLM4CS/ACM_jsonl
    /lus/eagle/projects/argonne_tpc/TextCollections/peS2o/JSON_data
)

for datasource in ${datasources[@]}
do

    echo "Datasource : $datasource"
    sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
    
    rm -rf /dev/shm/index
    mkdir -p /dev/shm/index/$sourcename

    # WARNING ======HACK======
    cp -R /lus/eagle/projects/argonne_tpc/arham/minhash/peS2o /dev/shm/index/peS2o/minhashes
    
    mkdir -p /dev/shm/index/$sourcename/minhashes
    mkdir -p /dev/shm/index/$sourcename/index
    cp -R 
    
    python -m deduplication \
	   --single \
	   --name $sourcename \
	   --input $datasource \
	   --minhash-dir /dev/shm/index/$sourcename/minhashes \
	   --save-dir /dev/shm/index/$sourcename/index \
	   --output-file /lus/eagle/projects/argonne_tpc/yadunand/index_individual/$sourcename.dupes.csv \
	   --num $(( 5 * 10**8 ))

    ls /dev/shm/index
    
    cp -R /dev/shm/index/$sourcename /lus/eagle/projects/argonne_tpc/yadunand/index_individual/

done
