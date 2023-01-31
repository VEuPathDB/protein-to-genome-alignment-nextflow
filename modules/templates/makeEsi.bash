#!/usr/bin/env bash

set -euo pipefail
esd2esi $targetEsd target.esi \
  --translate yes \
  --memorylimit $esd2esiMemoryLimit
