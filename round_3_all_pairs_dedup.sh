#!/bin/bash

set -e


source /home/yadunand/setup_agpt_env_3_no_insert.sh
# source /home/yadunand/setup_agpt_env_3.sh

cd /lus/eagle/projects/argonne_tpc/yadunand/

# rm -Rf /dev/shm/index
# TODO:1  Update this to match the latest index before runs
# cp -R /lus/eagle/projects/argonne_tpc/yadunand/index.PMC-OA /dev/shm/index
# cp -R /lus/eagle/projects/argonne_tpc/yadunand/index_combined_8/ /dev/shm/index
# mkdir /dev/shm/index


datasources=(
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/RP1
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/peS2o
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/ASM
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/Bioarxiv
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/LLM4CS
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/Medrxiv
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/NIH_LitArch
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/OSTI
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/PMC-OA

#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/IPCC
#    /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_2/DOEcode
)

output_dir=/lus/eagle/projects/argonne_tpc/yadunand/pairwise_dedups_round_2

find_duplicates() {

    minhash_dir=$1
    index_path=$2
    output_filename=$3
    pair_name=$4
    python -m deduplication --multi \
	   --name $pair_name \
	   --input $pair_name \
	   --minhash-dir $minhash_dir \
	   --save-dir $index_path \
	   --output-file $output_filename \
	   --num $(( 5 * 10**8 )) \
	   --skip-minhashing \
	   --skip-insertion
}

for datasource1 in ${datasources[@]}
do
    rm -rf /dev/shm/index
    cp -R $datasource1/index /dev/shm/index
    echo "Copied $datasource1/index to /dev/shm/index"

    for datasource2 in ${datasources[@]}
    do
	d1=$(basename $datasource1)
	d2=$(basename $datasource2)
	echo "Compare $d2 minhashes with $d1 index"

	# Check if this pair has been evaluated
	sorted_pair=$(echo "$d1 $d2" | xargs -n1 | sort | xargs | sed 's/ /./')

	echo "Evaluating sorted_pair: $sorted_pair"
	output_file=$output_dir/$sorted_pair.dedup.csv
	if [ ! -f $output_file ]
	then
	    echo "$output_file is not present. Computing dedup"
	    find_duplicates $datasource2/minhashes /dev/shm/index $output_file $sorted_pair
	else
	    echo "$output_file is present. Skipping dedup"
	fi
	
    done
done


