#!/usr/bin/env nextflow 
nextflow.enable.dsl=2


process miniprot {
  container='nanozoo/miniprot:2.24--0c673d2'

  input:
    path queryFile 
    path targetFile
    val maxIntronLen

  output:
    file 'alignments.gff'

  script:
    template 'miniprot.bash'
}


process makeResult {
  container = "veupathdb/proteintogenomealignment"
  publishDir "$params.outputDir", mode: "copy"

  input:
    file resultGff 

  output:
    path 'result.sorted.gff'
    path 'result.sorted.gz'
    path 'result.sorted.gz.tbi'

  script:
    template 'makeResult.bash'
}


workflow proteinToGenomeAlignment {
  take:
    seqs

  main:

    gff = miniprot(seqs, params.targetFilePath, params.maxintron)
    result = gff.collectFile(name: 'result.gff', keepHeader: true, skip: 1)
    output = makeResult(result)

}