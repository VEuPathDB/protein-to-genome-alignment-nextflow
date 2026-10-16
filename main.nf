#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Includes
//--------------------------------------------------------------------------

include { proteinToGenomeAlignment } from './modules/proteinToGenomeAlignment.nf'

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------

workflow {
  if(!params.queryChunkSize) {
    error "Missing params.queryChunkSize"
  }
  if(!params.queryFilePath) {
    error "Missing params.queryFilePath"
  }
  else {
    seqs = channel.fromPath( params.queryFilePath)
             .splitFasta( by:params.queryChunkSize, file:true  )
  }
  if(!params.targetFilePath) {
    error "Missing params.targetFilePath"
  }
  if(!params.outputDir) {
    error "Missing params.outputDir"
  }

  proteinToGenomeAlignment(seqs)
}