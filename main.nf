#!/usr/bin/env nextflow
 

proteins = Channel
    .fromPath(params.queryFilePath)
    .splitFasta(by: params.queryChunkSize, file:true)

process makeEsd {
    input:
    path 'target.fa' from params.targetFilePath
 
    output:
    path 'target.esd' into targets_esd

    """
    fasta2esd target.fa target.esd
    """
}

process makeEsi {
    input:
    path 'target.esd' from targets_esd
    path 'target.fa' from params.targetFilePath 

    output:
    path 'target.esi' into targets_esi

    """
    esd2esi target.esd target.esi --translate yes --memorylimit $params.esd2esiMemoryLimit
    """
}

process exonerate {
    input:
    file query_file from proteins
    path 'target.esd' from targets_esd
    path 'target.fa' from params.targetFilePath 
    path 'target.esi' from targets_esi    
    
    output:
    file 'alignments.gff' into alignments_ch

    """
    RANGE=13000
    FLOOR=8000    
    for (( i = 0 ; i <= 1000 ; i++ )); do
        randomNumber=0
	while [ "\$randomNumber" -le \$FLOOR ]
	do
	  randomNumber=\$RANDOM
	  let "randomNumber %= \$RANGE"
        done
        EXONERATE_EXONERATE_SERVER_PORT=\$randomNumber;
        exonerate-server --input target.esi --port \$EXONERATE_EXONERATE_SERVER_PORT & pid=\$!
        sleep 5;
        ps -p \$pid >/dev/null && break 1;
    done
    echo exonerate server running on port \$EXONERATE_EXONERATE_SERVER_PORT

    exonerate --fsmmemory $params.fsmmemory -n 1 --geneseed 250 -S n  --minintron 20 --maxintron $params.maxintron  --showcigar n --showvulgar n --showalignment n --showtargetgff y --model protein2genome --query $query_file --target localhost:\$EXONERATE_EXONERATE_SERVER_PORT >alignments.gff

    kill \$pid;
    """
}


process makeGff {
    input:
    file 'alignments.gff' from alignments_ch
    
    output:
    file 'fixed.gff' into fixed_ch
 
    '''
    #!/usr/bin/env perl
    use strict;

    open(FILE, "alignments.gff") or die "Cannot open file alignmments.gff for reading: $!";
    open(OUT, ">fixed.gff") or die "Cannot open file fixed.gff for writing: $!";
    my ($proteinId, $strand);
    my $cdsCount = 0;
    while(my $line = <FILE>) {
      chomp $line;
      my @a = split(/\\t/, $line);
      my $type = $a[2];
      if($type eq 'gene') {
        ($proteinId) = $a[8] =~ /sequence (\\S+)/;
        ($strand) = $a[8] =~ /gene_orientation (\\+|\\-)/;
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
      $a[6] = $strand;
      print OUT join("\\t", @a) . "\\n";
    }
    close FILE;
    close OUT;
   '''
}


results = fixed_ch
    .collectFile(name: 'result.gff')


process makeResult {
    input:
    file 'result.gff' from results
    
    """
    sort -k1,1 -k4,4n result.gff > $params.outputDir/result.sorted.gff
    bgzip $params.outputDir/result.sorted.gff
    tabix -p gff $params.outputDir/result.sorted.gff.gz
    """
}
