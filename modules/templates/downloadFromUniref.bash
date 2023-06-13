#!/usr/bin/env bash

set -euo pipefail

if [ "$projectName" = "FungiDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A4751%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta
    
elif [ "$projectName" = "AmoebaDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A554915%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta
    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A5752%29%29%20AND%20%28identity%3A0.5%29" -O secondFasta.fa
    cat secondFasta.fa >> uniRef_subset.fa
    
elif [ "$projectName" = "GiardiaDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A2611341%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta

elif [ "$projectName" = "CryptoDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=((taxonomy_id%3A1280412))%20AND%20(identity%3A0.5)" -O uniRef_subset.fasta
    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A877183%29%29%20AND%20%28identity%3A0.5%29" -O secondFasta.fa
    cat secondFasta.fa >> uniRef_subset.fa

elif [ "$projectName" = "MicrosporidiaDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_name%3AMicrosporidia%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta

elif [ "$projectName" = "PlasmoDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A5819%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta
    
elif [ "$projectName" = "PiroplasmaDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A5863%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta
    
elif [ "$projectName" = "ToxoDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A423054%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta

elif [ "$projectName" = "TrichDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=false&format=fasta&query=%28%28taxonomy_id%3A5719%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta
    
elif [ "$projectName" = "TriTrypDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=true&format=fasta&query=%28%28taxonomy_id%3A5653%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta

elif [ "$projectName" = "VectorDB" ]; then

    wget "https://rest.uniprot.org/uniref/stream?compressed=true&format=fasta&query=%28%28taxonomy_id%3A6656%29%29%20AND%20%28identity%3A0.5%29" -O uniRef_subset.fasta
    
else

    exit
    
fi


