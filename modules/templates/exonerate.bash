#!/usr/bin/env bash

set -euo pipefail
RANGE=13000
FLOOR=8000    
MAX_TRIES=12
for (( i = 0 ; i <= 1000 ; i++ )); do
  randomNumber=0
  while [ "\$randomNumber" -le \$FLOOR ]
	do
	  randomNumber=\$RANDOM
	  let "randomNumber %= \$RANGE"
        done
  EXONERATE_EXONERATE_SERVER_PORT=\$randomNumber;
  exonerate-server --input $targetEsi --port \$EXONERATE_EXONERATE_SERVER_PORT & pid=\$!
  ps -p \$pid >/dev/null && break 1;
done
for (( i=1; i<=\$MAX_TRIES; i++ ))
  do
  sleep 10
  echo Try \$i of \$MAX_TRIES to connect
   
  if echo version >/dev/tcp/localhost/\$EXONERATE_EXONERATE_SERVER_PORT; then
    echo exonerate server running on port \$EXONERATE_EXONERATE_SERVER_PORT
    exonerate --fsmmemory $fsmMemory -n 1 --geneseed 250 -S n  --minintron 20 --maxintron $maxIntron  --showcigar n --showvulgar n --showalignment n --showtargetgff y --model protein2genome --query $query_file --target localhost:\$EXONERATE_EXONERATE_SERVER_PORT >alignments.gff

    kill \$pid;
    exit 0

  else
     echo Connection Failed \$i of \$MAX_TRIES
  fi

 done
kill \$pid;
exit 1
