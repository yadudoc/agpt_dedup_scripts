# AGPT Deduplication guide


The document serves to record the steps taken to generate a deduplicated dataset
of scientific literature for dowstream model training/fine-tuning applications.

---

## Table of Contents

1. [Introduction](#introduction)  
2. [Requirements](#requirements)  
3. [Installation](#installation)
4. [Usage](#usage)

---

## 1. Introduction

Several works have shown that duplication of texts in training corpora can lead to subtle biases in the trained model.
We compile our dataset from several different sources that themselves have internal duplication in addition to having
duplication between each other.

Please refer to Arham's paper on details on the how these duplicates come about, how we use MinhashLSH to identify
duplicates in a fuzzy manner, details on the various tunable parameters, and how we've deterimined the parameter
set to use for our deduplication efforts.

---

## 2. Requirements

We've run experiments on ALCF's Polaris supercomputer and UChicago's Midway RCC. For the rest of the document
we will focus entirely on running on Polaris since we've got highly parallelized Parsl scripts to exploit
parallelism where possible.

---

## 3. Installation

```bash

# Create virtual environment (optional but recommended)
python3 -m venv .venv
source .venv/bin/activate


# Clone the repo https://github.com/TPC-AI/data-general-text-code-web
# Follow instructions listed to install in the data-general-text-code-web/deduplication directory

git clone https://github.com/TPC-AI/data-general-text-code-web.git
cd data-general-text-code-web/deduplication

# Install
pip install .

```

## 4. Usage

Due to the size of datasets there are two separate processing pipelines that we use to create
MinhashLSH bloom filters and generate a list of duplicates.

1. All our processing pipelines require datasets in `jsonl` format, where a single file
   contains several lines where each line is a json representation of a document.

2. If the jsonl files that comprise the dataset are larger than 100GB, we recommed using the
   Parsl based distributed Minhash script. In general generating the minhashes is roughly an
   order of magnitude more expensive compared to inserting a hash into the bloom filter. By
   parallelizing this step, we've observed ~16x speedup using 4 nodes.
   (1.8Tb from PRO dataset processed in 1.15hours on 4 Polaris nodes)

   Here's how to run the minhashing.py script:
   ```
   usage: minhashing.py [-h] --input_dir INPUT_DIR --output_dir OUTPUT_DIR --num_perm NUM_PERM

options:
  -h, --help            show this help message and exit
  --input_dir INPUT_DIR
                        Input directory with jsonl files
  --output_dir OUTPUT_DIR
                        Output directory to write pickle output files
  --num_perm NUM_PERM   Number of permutations in the minhash calculation
  ```

3. While it is possible to build a new index or insert into an existing index from raw jsonl
   files, the easier route is to first build a dataset specific index from jsonl files, or
   for larger datasets, using the minhashes computed in the previous step.

   For large datasets build the index from precomputed minhashes:

   ```
    # Make sure to set the bash variables
    
    python -m deduplication \
           --single \
           --name $sourcename \
           --input $datasource \
           --minhash-dir $minhashdir \     # Point minhashdir to precomputed minhashes
           --save-dir /dev/shm/index/$sourcename/index \
           --output-file /dev/shm/index/$sourcename/$sourcename.dupes.csv \
           --sim-threshold 0.6 \
           --fp 5.555500503649536e-12 \
           --skip-minhashing \
           --num $(( 5 * 10**8 )

    ```

   For smaller dataset compute the minhashes and the index together

     ```
     python -m deduplication \
           --single \
           --name $sourcename \
           --input $datasource \
           --minhash-dir $minhashdir \       # Minhashes will be written here.
           --save-dir /dev/shm/index/$sourcename/index \
           --output-file /dev/shm/index/$sourcename/$sourcename.dupes.csv \
           --sim-threshold 0.6 \
           --fp 5.555500503649536e-12 \
           --num $(( 5 * 10**8 ))

     ```

4. Once minhashes are computed for all relevant datasets, each dataset can be inserted into the
   filter iteratively:

   ```
   datasources=(
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/ASM.pymupdf
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/ACM
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/Bioarxiv
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/OSTI
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/Medrxiv
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/NIH_LitArch
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/PMC-OA
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/IPCC
       /lus/eagle/projects/argonne_tpc/yadunand/index_individual_round_3/CORE
   )

   OUTPUT_DIR=/lus/eagle/projects/argonne_tpc/yadunand/combined_index_round_3

   cd /lus/eagle/projects/argonne_tpc/yadunand/

   rm -Rf /dev/shm/combined
   echo "Copying index to /dev/shm/combined/index"
   mkdir -p /dev/shm/combined/
   cp -R /lus/eagle/projects/argonne_tpc/yadunand/combined_index_round_3/index /dev/shm/combined/

   for datasource in ${datasources[@]}
   do
       sourcename=$(basename $datasource)
       echo "Trying to find duplicates from $sourcename in combined index"

       DUPS_OUTPUT=$OUTPUT_DIR/$sourcename.dupes.csv

       python -m deduplication \
	      --single \
	      --name $sourcename \
	      --input $datasource \
	      --minhash-dir $datasource/minhashes \
	      --skip-minhashing \
	      --save-dir /dev/shm/combined/index \
	      --output-file /dev/shm/combined/$sourcename.dupes.csv \
	      --sim-threshold 0.6 \
	      --fp 5.555500503649536e-12 \
	      --num $(( 5 * 10**8 ))

   done
   ```# agpt_dedup_scripts
