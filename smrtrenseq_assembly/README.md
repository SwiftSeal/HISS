# Assembly of SMRT-RenSeq HiFi data

**NOTE This workflow assumes that the only trimming needed is from the 5' and 3' end. Always check that your trimming results look sensible and keep in mind you may need to remove reverse complements of your adaptors. This workflow DOES NOT do this and should only be regarded as providing minimal trimming. Please also note the NLR coverage values reported by the workflow are only calculated for those marked as complete to avoid possible bias in enrichment across gene lengths**

## Usage

*   A tab delimited text file with one line per sample and the header line (use absolute file paths and fastq files for reads): sample Reads

5.  Make modifications to the config.yaml file. This follows the yaml format of key-value pairs. Keep the keys as they are, but change the value they are paired with as explained below:

    *   samples - replace the quoted text with the path to your sample sheet
    *   fiveprime - replace the quoted text with the sequence to be trimmed from the 5' end of the reads
    *   threeprime - replace the quoted text with the sequence to be trimmed from the 3' end of the reads
    *   Genome_Size - replace the quoted text with the estimated size of the assembly. Don't worry about being too precise, it seems to only affect the coverage estimate which is less important for HiCanu than in Canu.
    *   flanking - replace the quoted text with the number of flanking bases to be used for extracting the fastas of NLR Annotator hits. I use 1,000 bp.

## Results

TODO
