#!/usr/bin/env nextflow

process makeEsd {
  input:
    path targetFasta
 
  output:
    path 'target.esd'

  script:
    template 'makeEsd.bash'
}

process makeEsi {
  input:
    path targetEsd
    path targetFasta
    val esd2esiMemoryLimit

  output:
    path 'target.esi'
    
  script:
    template 'makeEsi.bash'
}

process exonerate {
  input:
    path queryFile
    path targetEsd
    path targetFasta
    path targetEsi
    val fsmMemory
    val maxIntron
    
  output:
    path 'alignments.gff'

  script:
    template 'exonerate.bash'
}

process makeGff {
  input:
    path alignmentsGff
    
  output:
    path 'fixed.gff'

  script:
    template 'makeGff.bash'
}

process makeResult {
  publishDir "$params.outputDir", mode: "copy", pattern: 'result.sorted.gff*'

  input:
    path resultGff

  output:
    path 'result.sorted.gff', emit: sorted_gff
    path 'result.sorted.gff.gz', emit: sorted_gz
    path 'result.sorted.gff.gz.tbi', emit: sorted_gztbi

  script:
    template 'makeResult.bash'
}

workflow proteinToGenomeAlignment {
  take:
    seqs

  main:
    esd = makeEsd(params.targetFilePath)
    esi = makeEsi(esd, params.targetFilePath, params.esd2esiMemoryLimit)
    gff = exonerate(seqs, esd, params.targetFilePath, esi, params.fsmmemory, params.maxintron)
    result = makeGff(gff).collectFile(name: 'result.gff')
    output = makeResult(result)
}