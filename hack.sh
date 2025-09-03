#!/bin/bash

set -e

eval "$(/eagle/argonne_tpc/yadunand/anaconda3/bin/conda shell.bash hook)"
# conda activate 3_agpt_py3.11
conda activate agpt_2_py3.11
# source ~/setup_agpt_env.sh


cd /lus/eagle/projects/argonne_tpc/yadunand/

# rm -Rf /dev/shm/index
# TODO:1  Update this to match the latest index before runs
# cp -R /lus/eagle/projects/argonne_tpc/yadunand/index.PMC-OA /dev/shm/index
# cp -R /lus/eagle/projects/argonne_tpc/yadunand/index_combined_8/ /dev/shm/index
# mkdir /dev/shm/index


datasources=(
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/IPCC
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/DOEcode
)

output_dir=/lus/eagle/projects/argonne_tpc/yadunand/pairwise_dedups

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
    # cp -R $datasource1/index /dev/shm/index
    echo "HACCCCCCCCCCKKKKKKKKKKKKKKKKK***************************************************************************************************"
    cp -R /eagle/argonne_tpc/arham/dedup_paper_experiments/scaling_experiments/peS2o_subsets/subset_100/results/bloom_filter /dev/shm/index
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


