# protein-to-genome-alignment-nextflow

A Nextflow pipeline that aligns protein sequences to a genome assembly using Exonerate's `protein2genome` model.

## Overview

This pipeline spliced-aligns a set of query protein sequences against a target genome using [Exonerate](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate), producing a GFF of gene structures inferred from the alignments. It is used within VEuPathDB's genome annotation workflows to project protein evidence (e.g. from related organisms or existing gene models) onto a genome assembly to support gene-structure annotation. The target genome is indexed once with `fasta2esd`/`esd2esi`, the query proteins are split into chunks and aligned in parallel against an `exonerate-server` instance serving that index, the raw alignment GFF is reformatted into clean gene/CDS records, and the combined result is sorted, compressed with `bgzip`, and indexed with `tabix`.

## Requirements

- [Nextflow](https://www.nextflow.io/) (DSL2)
- Docker (enabled by default via `nextflow.config`)

The pipeline uses the `veupathdb/proteintogenomealignment:1.0.0` container image for the exonerate/indexing steps and `biocontainers/tabix:v1.9-11-deb_cv1` for sorting and indexing the final output.

## Usage

```
nextflow run VEuPathDB/protein-to-genome-alignment-nextflow \
  -r main \
  --queryFilePath /path/to/proteins.fa \
  --targetFilePath /path/to/genome.fa \
  --outputDir /path/to/output \
  --outputFileName nrProteinToGenome.gff \
  --queryChunkSize 100 \
  -profile docker \
  -resume
```

The pipeline has a single named workflow entry point, `proteinToGenomeAlignment`, which is invoked automatically by the top-level `workflow` block in `main.nf`. It performs the full process: indexing the target genome, running `exonerate` per query chunk against an `exonerate-server`, reformatting the alignment output into gene/CDS GFF records, and sorting/compressing/indexing the combined result.

## Key Parameters

| Parameter | Description |
| --- | --- |
| `params.queryFilePath` | Path to the FASTA file of query protein sequences to align. |
| `params.targetFilePath` | Path to the target genome FASTA file. |
| `params.queryChunkSize` | Number of query sequences per FASTA chunk sent to a single `exonerate` process; controls the degree of parallelism. |
| `params.esd2esiMemoryLimit` | Memory limit (MB) passed to `esd2esi` when building the target sequence index. |
| `params.fsmmemory` | Memory limit (MB) passed to `exonerate`'s finite state machine (`--fsmmemory`). |
| `params.maxintron` | Maximum intron size passed to `exonerate --maxintron` when modeling spliced alignments. |
| `params.outputDir` | Directory where the final indexed GFF is published. |
| `params.outputFileName` | File name for the final published GFF (default: `nrProteinToGenome.gff`). |

## Output

A `bgzip`-compressed, `tabix`-indexed GFF file (`<outputFileName>.gz` and its `.tbi` index) containing gene and CDS features derived from the protein-to-genome alignments, sorted by sequence and start coordinate.
