#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

if(!params.queryChunkSize) {
  throw new Exception("Missing params.queryChunkSize")
}
if(!params.queryFilePath) {
  throw new Exception("Missing params.queryFilePath")
}
else {
  seqs = Channel.fromPath( params.queryFilePath)
           .splitFasta( by:params.queryChunkSize, file:true  )
}
if(!params.targetFilePath) {
  throw new Exception("Missing params.targetFilePath")
}
if(!params.outputDir) {
  throw new Exception("Missing params.outputDir")
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