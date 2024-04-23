#!/usr/bin/env bash

set -euo pipefail

sort -k1,1 -k4,4n $resultGff > result.sorted.gff
cp result.sorted.gff hold.gff
bgzip result.sorted.gff
mv hold.gff result.sorted.gff
tabix -p gff result.sorted.gff.gz
