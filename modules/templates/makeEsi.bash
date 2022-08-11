#!/usr/bin/env bash

esd2esi target.esd target.esi \
  --translate yes \
  --memorylimit $params.esd2esiMemoryLimit
