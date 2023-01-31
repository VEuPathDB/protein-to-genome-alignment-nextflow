#!/usr/bin/env bash

set -euo pipefail
sort -k1,1 -k4,4n $resultGff > result.sorted.gff
cat result.sorted.gff > result.sorted
bgzip result.sorted
tabix -p gff result.sorted.gz
