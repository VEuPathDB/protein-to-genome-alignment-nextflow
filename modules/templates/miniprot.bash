#!/usr/bin/env bash

set -euo pipefail

miniprot -K 5M -G $maxIntronLen -N 5 --gff-only $targetFile $queryFile > alignments.gff
