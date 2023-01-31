#!/usr/bin/env nextflow 
nextflow.enable.dsl=2


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
    file query_file 
    path targetEsd
    path targetFasta 
    path targetEsi
    val fsmMemory
    val maxIntron

  output:
    file 'alignments.gff'

  script:
    template 'exonerate.bash'
}


process makeGff {
  input:
    file alignmentsGff

  output:
    file 'fixed.gff'

  script:
    template 'makeGff.bash'
}


process makeResult {
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
    esd = makeEsd(params.targetFilePath)
    esi = makeEsi(esd, params.targetFilePath, params.esd2esiMemoryLimit)
    gff = exonerate(seqs, esd, params.targetFilePath, esi, params.fsmmemory, params.maxintron)
    result = makeGff(gff).collectFile(name: 'result.gff')
    output = makeResult(result)
    output.sorted_gff | collectFile(storeDir: params.outputDir)
    output.sorted_gz | collectFile(storeDir: params.outputDir)
    output.sorted_gztbi | collectFile(storeDir: params.outputDir)

}