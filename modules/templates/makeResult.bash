#!/usr/bin/env bash

sort -k1,1 -k4,4n result.gff > result.sorted.gff
cat result.sorted.gff > result.sorted
bgzip result.sorted
tabix -p gff result.sorted.gz
