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


process makeEsd {
  container = "veupathdb/proteintogenomealignment"
  input:
    path targetFasta  

  output:
    path 'target.esd'

  script:
    template 'makeEsd.bash'
}


process makeEsi {
  container = "veupathdb/proteintogenomealignment"
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
  container = "veupathdb/proteintogenomealignment"
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
  container = "veupathdb/proteintogenomealignment"
  input:
    file alignmentsGff

  output:
    file 'fixed.gff'

  script:
    template 'makeGff.bash'
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

    makeEsdResults = makeEsd(params.genomeFilePath)
    makeEsiResults = makeEsi(makeEsdResults,params.genomeFilePath,params.esd2esiMemoryLimit)
    exonerateResults = exonerate(unirefFasta,makeEsdResults,params.genomeFilePath,makeEsiResults,params.fsmmemory,params.maxIntron)
    makeGffResults = makeGff(exonerateResults)
    output = makeResult(makeGffResults)

    output.sorted_gff | collectFile(storeDir: params.outputDir)
    output.sorted_gz | collectFile(storeDir: params.outputDir)
    output.sorted_gztbi | collectFile(storeDir: params.outputDir)

}