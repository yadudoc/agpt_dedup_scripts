#!/bin/bash

datasources=(
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/peS2o
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/ASM
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/Bioarxiv
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/LLM4CS
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/Medrxiv
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/NIH_LitArch
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/OSTI
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/PMC-OA
    /lus/eagle/projects/argonne_tpc/yadunand/index_individual/RP1    
)

for datasource in ${datasources[@]}
do
    python3 count_minhashes.py -m $datasource/minhashes
done
