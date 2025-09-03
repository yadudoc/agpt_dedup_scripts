#!/bin/bash
set -ex

indices=(
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/Bioarxiv
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/LLM4CS
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/Medrxiv
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/NIH_LitArch
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/OSTI
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/PMC-OA
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/RP1
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/peS2o
)

minhashes=(
    /lus/eagle/projects/argonne_tpc/yadunand/minhashes/Bioarxiv
    /lus/eagle/projects/argonne_tpc/yadunand/minhashes/Medrxiv
    /lus/eagle/projects/argonne_tpc/yadunand/minhashes/NIH_LitArch
    /lus/eagle/projects/argonne_tpc/yadunand/minhashes/OSTI
    /lus/eagle/projects/argonne_tpc/yadunand/minhashes/PMC-OA
    /lus/eagle/projects/argonne_tpc/yadunand/minhashes/TextCollections
)

echo "Here"
mkdir -p "/dev/shm/index"

for source_index in ${indices[@]}
do
    echo "Index: $source_index"

    index_name=$(basename $source_index)
    index="/dev/shm/index/$index_name"

    for target_minhashes in ${minhashes[@]}
    do

	# Wipe previous index that could have been polluted
	rm -rf $index
	cp -R $source_index $index

	target_name=$(basename $target_minhashes)
	echo "Starting dedup of $target_name against index:$index"
	
	python -m deduplication \
	       --multi \
	       --skip-minhashing \
	       --name $index_name.$target_name \
	       --input $target_minhashes \
	       --minhash-dir $target_minhashes \
	       --save-dir $index \
	       --output-file /lus/eagle/projects/argonne_tpc/yadunand/pairwise_overlap/$index_name.$target_name.dupes.csv \
	       --num $(( 5 * 10**8 ))
    

    done
done
