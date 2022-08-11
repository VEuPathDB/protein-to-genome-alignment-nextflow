#!/usr/bin/env nextflow 
nextflow.enable.dsl=2


process makeEsd {
  input:
    path 'target.fa'  

  output:
    path 'target.esd'

  script:
    template 'makeEsd.bash'
}


process makeEsi {
  input:
    path 'target.esd' 
    path 'target.fa' 
  output:
    path 'target.esi' 

  script:
    template 'makeEsi.bash'
}


process exonerate {
  input:
    file query_file 
    path 'target.esd'
    path 'target.fa' 
    path 'target.esi'

  output:
    file 'alignments.gff'

  script:
    template 'exonerate.bash'
}


process makeGff {
  input:
    file 'alignments.gff'

  output:
    file 'fixed.gff'

  script:
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

  script:
    template 'makeResult.bash'
}


workflow proteinToGenomeAlignment {
  take:
    seqs
  main:
    esd = makeEsd(params.targetFilePath)
    esi = makeEsi(esd, params.targetFilePath)
    gff = exonerate(seqs, esd, params.targetFilePath, esi)
    result = makeGff(gff).collectFile(name: 'result.gff')
    output = makeResult(result)
    output[0] | collectFile(storeDir: params.outputDir)
    output[1] | collectFile(storeDir: params.outputDir)
    output[2] | collectFile(storeDir: params.outputDir)
}