# AgRenSeq Snakemake pipeline

AgRenSeq requires several intermediate steps - this pipeline consolidates this into a single process allowing the user to quickly adjust input files or parameters.
Currently, this pipeline uses the java AgRenSeq version, as the python GLM-approach is not usable.

## Setup

This pipeline uses conda to contain certain processes and ensure replicability across different systems.
It has been tested with with conda base environment with the following installations: 

```
Python 3.10.5
Cookiecutter 2.1.1
Snakemake 7.12.1
```

Other dependencies are handled via Snakemake.

## Usage

All inputs and parameters are handled in the config/ directory.
config.yaml currently takes five  options:

* `read_scores` which contains the relative path of `read_scores.txt` to the base directory
* `assembly` which contains the relative path to the `.fasta` file of contigs you wish to use as a reference
* `assembly_title` which will be a string that is used as a title in the final plots (no whitespace!)
* `reference` which should be the relative path to a reference genome  `.fasta` for BLAST plotting.
* `assoc_threshold` which will set the threshold used to filter contigs by agrenseq association, and plot on the BLAST plot

I recommend keeping all files in the config directory to keep it tidy :)

`read_scores.txt` is a tab separated file with four columns, `sample R1 R2 score`.
Each row contains the name, *absolute path* to illumina .fastq.gz R1 and R2, and the phenotype score for each accession passed into the AgRenSeq pipeline.
This pipeline uses fastp to trim and QC reads, it should be safe to pass through reads that have already been trimmed, but double check the `.json` outputs if uncertain.
I find fastp fairly unaggressive and will only result in a minor loss of data.
For the reference genome, I strongly recommend one with only the major chromosomes reported, and not 100+ scaffold sequences, as that will make the plot unreadable.

### Example plots

![AgRenSeq Rorschach plot](README_misc/AgRenSeq_plot.png)

![BLAST plot](README_misc/blast_plot.png)

Certain parameters specific to the crop diversity HPC SLURM system are hardcoded in the snakemake rules, these may need to be adjusted.
Most steps will take under 30 minutes to run, so a short queue is sufficient.

To run the full pipeline, run the following in the base directory:

`snakemake --use-conda --profile /path/to/your/cluster/profile --jobs max_number_of_simultaneous_jobs`

the `--profile` should be created via cookiecutter with default options.

Results are contained with two directories, `images/` and `results/`.
In results, `AgRenSeqResult.txt` is the final output of AgRenSeq, `output.nlr.txt` is a list of contigs associated with nlr motifs, and `jellyfish/` cotains the `.dump` files for each accession in `read_scores.txt`.
`images/` will contain a basic plot of the AgRenSeq results, as well as a plot of best blast hits against a reference genome (I recommend DM).

A `logs/` directory will be created and populated with logs of certain processes.
