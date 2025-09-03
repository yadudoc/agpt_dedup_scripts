#!/bin/bash


datasources=(
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/Bioarxiv.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/Medrxiv.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/NIH_LitArch.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/OSTI.nougat/parsed_pdfs
    #/lus/eagle/projects/argonne_tpc/hippekp/agpt-data/PMC-OA.nougat/parsed_pdfs
    /lus/eagle/projects/argonne_tpc/TextCollections/RP1/arxiv
)

for datasource in ${datasources[@]}
do
    echo "Datasource : $datasource"
    sourcename=$(basename $(dirname $datasource) | sed 's/.nougat//' )
    echo "Writing output to /lus/eagle/projects/argonne_tpc/yadunand/deduped/$sourcename/$sourcename.{}.jsonl "
    mkdir /lus/eagle/projects/argonne_tpc/yadunand/deduped/$sourcename
    ./deduplicator/deduplicator \
	-p RP1_arxiv:$datasource \
	-l 100000 \
	-o /lus/eagle/projects/argonne_tpc/yadunand/deduped/$sourcename/$sourcename.{}.jsonl \
	: duplicates_csv/$sourcename.dupes.csv
done
