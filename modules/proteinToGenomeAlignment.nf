#!/usr/bin/env nextflow

process makeEsd {
  container = "veupathdb/proteintogenomealignment:v1.0.0"

  input:
    path targetFasta
 
  output:
    path 'target.esd'

  script:
    template 'makeEsd.bash'
}

process makeEsi {
  container = "veupathdb/proteintogenomealignment:v1.0.0"

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
  container = "veupathdb/proteintogenomealignment:v1.0.0"

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
  container = "veupathdb/proteintogenomealignment:v1.0.0"

  input:
    path alignmentsGff
    
  output:
    path 'fixed.gff'

  script:
    template 'makeGff.bash'
}

process indexResults {
  container = 'biocontainers/tabix:v1.9-11-deb_cv1'

  publishDir params.outputDir, mode: 'copy'

  input:
    path gff
    val outputFileName

  output:
    path '*.gz'
    path '*.gz.tbi'

  script:
  """
  sort -k1,1 -k4,4n $gff > ${outputFileName}
  bgzip ${outputFileName}
  tabix -p gff ${outputFileName}.gz
  """
}


workflow proteinToGenomeAlignment {
  take:
    seqs

  main:
    esd = makeEsd(params.targetFilePath)
    esi = makeEsi(esd, params.targetFilePath, params.esd2esiMemoryLimit)
    gff = exonerate(seqs, esd, params.targetFilePath, esi, params.fsmmemory, params.maxintron)
    result = makeGff(gff).collectFile()
    output = indexResults(result, params.outputFileName)
}
