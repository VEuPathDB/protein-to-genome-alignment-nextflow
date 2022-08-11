#!/usr/bin/env nextflow 
nextflow.enable.dsl=2


//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

if(params.queryFilePath) {
  seqs = Channel.fromPath(params.queryFilePath).splitFasta(by: params.queryChunkSize, file:true)
}
else {
  throw new Exception("Missing params.queryFilePath")
}

//--------------------------------------------------------------------------
// Includes
//--------------------------------------------------------------------------

include { proteinToGenomeAlignment } from './modules/proteinToGenomeAlignment.nf'

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------


workflow {
    
  proteinToGenomeAlignment(seqs)

}
