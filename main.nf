#!/usr/bin/env nextflow 

nextflow.enable.dsl=2

process makeEsd {
    input:
    path 'target.fa'  
    output:
    path 'target.esd'
    """
    fasta2esd target.fa target.esd
    """
}


process makeEsi {
    input:
    path 'target.esd' 
    path 'target.fa' 
    output:
    path 'target.esi' 
    """
    esd2esi target.esd target.esi \
      --translate yes \
      --memorylimit $params.esd2esiMemoryLimit
    """
}


process exonerate {
    input:
    file query_file 
    path 'target.esd'
    path 'target.fa' 
    path 'target.esi'
    output:
    file 'alignments.gff'
    """
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
        exonerate-server --input target.esi --port \$EXONERATE_EXONERATE_SERVER_PORT & pid=\$!
        ps -p \$pid >/dev/null && break 1;
    done
for (( i=1; i<=\$MAX_TRIES; i++ ))
 do
   sleep 10
   echo Try \$i of \$MAX_TRIES to connect
   
   if echo version >/dev/tcp/localhost/\$EXONERATE_EXONERATE_SERVER_PORT; then
    echo exonerate server running on port \$EXONERATE_EXONERATE_SERVER_PORT
    exonerate --fsmmemory $params.fsmmemory -n 1 --geneseed 250 -S n  --minintron 20 --maxintron $params.maxintron  --showcigar n --showvulgar n --showalignment n --showtargetgff y --model protein2genome --query $query_file --target localhost:\$EXONERATE_EXONERATE_SERVER_PORT >alignments.gff

    kill \$pid;
    exit 0

   else
     echo Connection Failed \$i of \$MAX_TRIES
   fi

 done
kill \$pid;
exit 1
    """
}


process makeGff {
    input:
    file 'alignments.gff'
    output:
    file 'fixed.gff'
    '''
    #!/usr/bin/env perl
    use strict;

    open(FILE, "alignments.gff") or die "Cannot open file alignmments.gff for reading: $!";
    open(OUT, ">fixed.gff") or die "Cannot open file fixed.gff for writing: $!";
    my ($proteinId);
    my $cdsCount = 0;
    while(my $line = <FILE>) {
      chomp $line;
      my @a = split(/\\t/, $line);
      my $type = $a[2];
      if($type eq 'gene') {
        ($proteinId) = $a[8] =~ /sequence (\\S+)/;
        $cdsCount = 0;
      }
      if($type eq 'cds') {
        $cdsCount++;
        $a[8] = "ID=${proteinId}_cds_${cdsCount};Parent=${proteinId}";
      }
      elsif($type eq 'similarity') {
        $a[8] = "ID=${proteinId}";
      }
      else {
        next;
      }
      print OUT join("\\t", @a) . "\\n";
    }
    close FILE;
    close OUT;
   '''
}


process makeResult {
    input:
    file 'result.gff' 
    output:
    file 'result.sorted.gff' 
    file 'result.sorted.gz' 
    file 'result.sorted.gz.tbi'
    """
    sort -k1,1 -k4,4n result.gff > result.sorted.gff
    cat result.sorted.gff > result.sorted
    bgzip result.sorted
    tabix -p gff result.sorted.gz
    """
}


workflow {
  proteins = Channel.fromPath(params.queryFilePath).splitFasta(by: params.queryChunkSize, file:true)
  esd = makeEsd(params.targetFilePath)
  esi = makeEsi(esd, params.targetFilePath)
  gff = exonerate(proteins, esd, params.targetFilePath, esi)
  result = makeGff(gff).collectFile(name: 'result.gff')
  output = makeResult(result)
  output[0] | collectFile(storeDir: params.outputDir)
  output[1] | collectFile(storeDir: params.outputDir)
  output[2] | collectFile(storeDir: params.outputDir)
}

