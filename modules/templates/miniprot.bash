#!/usr/bin/env bash

set -euo pipefail

miniprot -gff -G $maxIntronLen $queryFile $unirefFasta > alignments.gff

