#!/bin/bash

#PBS -S /bin/bash
#PBS -N Argonne_TPC_DEDUP
#PBS -m n
#PBS -l walltime=03:00:00
#PBS -l select=1:ncpus=32:ngpus=4
#PBS -o /eagle/argonne_tpc/yadunand/round_2_index.submit.stdout
#PBS -e /eagle/argonne_tpc/yadunand/round_2_index.submit.stderr
#PBS -l filesystems=home:grand:eagle
#PBS -A argonne_tpc
#PBS -q preemptable
set -e

source /home/yadunand/setup_agpt_env_3.sh

pending=(
    /lus/eagle/projects/argonne_tpc/TextCollections/peS2o/JSON_data/
)

datasources=(
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/Bioarxiv.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/Medrxiv.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/NIH_LitArch.nougat/parsed_pdfs
    # /lus/eagle/projects/LLM4CS/ACM_jsonl
    #/lus/eagle/projects/argonne_tpc/yadunand/DOEcode/
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/PMC-OA.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/IPCC.nougat/parsed_pdfs
    # /lus/eagle/projects/argonne_tpc/hippekp/agpt-data/OSTI.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/chia-clark/PretrainingData
    #/lus/eagle/projects/argonne_tpc/TextCollections/RP1/arxiv
    #/lus/eagle/projects/argonne_tpc/TextCollections/peS2o/JSON_data
    #/eagle/projects/argonne_tpc/TanjinHePublic/materials_science_papers
    #/lus/eagle/projects/argonne_tpc/TanjinHePublic/materials_science_papers/IOP_20250401
    # /lus/eagle/projects/LLM4CS/parsed
    #/lus/eagle/projects/argonne_tpc/TextCollections/CoreParsed
    # /lus/eagle/projects/argonne_tpc/TextCollections/Pro/parsed
    # /lus/eagle/projects/argonne_tpc/hippekp/agpt-data/ASM.pymupdf/parsed_pdfs/
    /eagle/projects/argonne_tpc/runderwood/parses/pro_reparse/parsed_pdfs
    # This is only for testing
    #/lus/eagle/projects/argonne_tpc/yadunand/anomaly_investigation/PRO_search/
)

# OUTPUT_DIR=/lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2
OUTPUT_DIR=/lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3
# OUTPUT_DIR=/lus/eagle/projects/argonne_tpc/yadunand/anomaly_investigation/PRO_search/
mkdir -p $OUTPUT_DIR

for datasource in ${datasources[@]}
do

    echo "Datasource : $datasource"
    sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
    
    if [ ! -d $OUTPUT_DIR/$sourcename/index ]
    then
        echo "$datasource is not yet processed. Computing index"
    else
        echo "$output_file is present. Skipping dedup"
	continue
    fi
    
    
    rm -rf /dev/shm/index
    mkdir -p /dev/shm/index/$sourcename
    mkdir -p /dev/shm/index/$sourcename/minhashes
    mkdir -p /dev/shm/index/$sourcename/index
    
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
    
    cp -R /dev/shm/index/$sourcename $OUTPUT_DIR/

done
