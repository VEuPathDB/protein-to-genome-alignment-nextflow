#!/usr/bin/env nextflow 
nextflow.enable.dsl=2


process downloadFromUniref {
  container = 'veupathdb/diamondsimilarity'
  input:
    val projectName

  output:
    path 'uniRef_subset.fasta'

  script:
    template 'downloadFromUniref.bash'
}


process miniprot {
  container='nanozoo/miniprot:2.24--0c673d2'
  publishDir "$params.outputDir", mode: "copy"   

  input:
    path queryFile 
    path unirefFasta
    val maxIntronLen

  output:
    file 'alignments.gff'

  script:
    template 'miniprot.bash'
}


process makeResult {
  container = "veupathdb/proteintogenomealignment"
  input:
    file resultGff 

  output:
    path 'result.sorted.gff', emit: sorted_gff 
    path 'result.sorted.gz', emit: sorted_gz
    path 'result.sorted.gz.tbi', emit: sorted_gztbi

  script:
    template 'makeResult.bash'
}


workflow proteinToGenomeAlignment {
  take:
    seqs

  main:

    unirefFasta = downloadFromUniref(params.projectName)

    miniprotResults = miniprot(unirefFasta,seqs, params.maxIntronLen)

    output = makeResult(miniprotResults)

    output.sorted_gff | collectFile(storeDir: params.outputDir)
    output.sorted_gz | collectFile(storeDir: params.outputDir)
    output.sorted_gztbi | collectFile(storeDir: params.outputDir)

}