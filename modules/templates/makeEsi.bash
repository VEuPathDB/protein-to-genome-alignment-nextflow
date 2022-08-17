#!/usr/bin/env bash

set -euo pipefail
esd2esi target.esd target.esi \
  --translate yes \
  --memorylimit $params.esd2esiMemoryLimit
