#!/usr/bin/env bash

set -euo pipefail

miniprot --gff -G $maxIntronLen $targetFile $unirefFasta > temp.gff

grep "miniprot" temp.gff > alignments.gff

