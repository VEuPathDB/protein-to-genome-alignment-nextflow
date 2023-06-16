#!/usr/bin/env bash

set -euo pipefail
perl /usr/bin/makeGff.pl --gffFile $alignmentsGff
