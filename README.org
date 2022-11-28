* proteinToGenomeAlignment

Description of nextflow configuration parameters

| param         | value type        | description  |
| ------------- | ------------- | ------------ |
| inputFilePath  | string | Path to input file |
| queryFilePath | path | Path to query fasta file | 
| targetFilePath | path | Path to genome fasta file |
| outputDir | path | Path to dir where you would like results stored |
| queryChunkSize | int | Splits fasta into smaller fastas containing the queryChunkSize number of reads. |
| esd2esiMemoryLimit | int | esd2esi memory limit |
| fsmmemory | int | Exonerate memory limit |
| maxintron | int | Value for --maxintron parameter for exonerate |

** Get Started
   + Install Nextflow
     #+begin_example
     curl https://get.nextflow.io | bash 
     #+end_example
   + Run the sample
     #+begin_example
     nextflow run VEuPathDB/proteinToGenomeAlignment -with-trace --outputDir <DESTDIR>
     #+end_example
   + Run the script for real
     #+begin_example
     nextflow run VEuPathDB/proteinToGenomeAlignment -with-trace -C  <config_file>
     #+end_example
