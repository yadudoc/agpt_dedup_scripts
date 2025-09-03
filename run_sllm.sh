#!/bin/bash


source ~/2_setup_sllm.sh

sllm-store-server --storage_path $SCRATCH/.cache/huggingface/hub --mem_pool_size 100 &

echo "Spawned server $! $?"
