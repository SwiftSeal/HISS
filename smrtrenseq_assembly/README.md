# README for assembling SMRT RenSeq HiFi data for potato

**NOTE This workflow assumes that the only trimming needed is from the 5' and 3' end. Always check that your trimming results look sensible and keep in mind you may need to remove reverse complements of your adaptors. This workflow DOES NOT do this and should only be regarded as providing minimal trimming. Please also note the NLR coverage values reported by the workflow are only calculated for those marked as complete to avoid possible bias in enrichment across gene lengths**

## Why Snakemake?

Snakemake is a workflow manager that uses python syntax. In short, it allows for an entire workflow that traditionally would be separated into multiple bash scripts to be run with a single command. It will also intelligently handle resources, job execution order and monitoring for errors to improve efficiency. Documentation on Snakemake is available here: <https://snakemake.readthedocs.io/en/stable/>

## Running the Snakemake workflow

### Preparation steps

There are a few things you need to set up prior to running the workflow with Snakemake.

1.  Install either Anaconda or Miniconda, Miniconda is more lightweight so I recommend this option. <https://docs.conda.io/en/latest/miniconda.html>

    I also recommend installing the alternative dependency resolver mamba, it's the default for Snakemake and is far quicker than base conda <https://anaconda.org/conda-forge/mamba>

```bash
conda install mamba
```

You will also need to install pandas

```bash
# With mamba
mamba install pandas

# With base conda
conda install pandas
```

2.  Install Snakemake into your base conda environment

```bash
# If mamba has been installed
mamba install snakemake

# If using only base conda
conda install snakemake
```

3.  Collect the right files in your desired directory. You need the following files:

    *   The Snakefile  
    *   A config file: config.yaml
    *   two scripts from this repository, parse_coverage.py and NLR_Annotator_to_bed.py
    *   A tab delimited text file with one line per sample and the header line (use absolute file paths and fastq files for reads): sample Reads
    *   The conda environments directory included in this repository

4.  Install required software

NLR Annotator is used in this pipeline and is not available via conda. Install instructions for it are available on the developers Github <https://github.com/steuernb/NLR-Annotator>

A pre-requisite for NLR-Annotator is having a JRE installed. If this is not yet the case, then install this into your base environment with the following commands

```bash
# Test if you have the java executable in your path, if you do then don't worry. If not, you'll need to install it.
which java

# With mamba
mamba install openjdk

# If using only base conda
conda install openjdk
```

Then follow the instructions to install NLR Annotator, don't worry about the meme prerequisite, snakemake handles this via conda.

5.  Make modifications to the config.yaml file. This follows the yaml format of key-value pairs. Keep the keys as they are, but change the value they are paired with as explained below:

    *   samples - replace the quoted text with the path to your sample sheet
    *   fiveprime - replace the quoted text with the sequence to be trimmed from the 5' end of the reads
    *   threeprime - replace the quoted text with the sequence to be trimmed from the 3' end of the reads
    *   Genome_Size - replace the quoted text with the estimated size of the assembly. Don't worry about being too precise, it seems to only affect the coverage estimate which is less important for HiCanu than in Canu.
    *   path_to_chopsequence_jar - replace the quoted text with the path to your installed chopsequence.jar from NLR Annotator
    *   path_to_NLR_Parser_jar - replace the quoted text with the path to your installed NLR_Parser.jar from NLR Annotator
    *   path_to_meme_xml - replace the quoted text with the path to the meme xml file from NLR Annotator
    *   path_to_NLR_Annotator_jar - replace the quoted text with the path to your installed NLR_Annotator.jar from NLR Annotator
    *   flanking - replace the quoted text with the number of flanking bases to be used for extracting the fastas of NLR Annotator hits. I use 1,000 bp.
    *   nlr_to_bed_script - replace the quoted text with the path to NLR_Annotator_to_bed.py (in this repository)
    *   path_to_parse_coverage_script - replace the quoted text with the path to parse_coverage.py (in this repository)

6.  If running in a cluster environment, create a profile

Snakemake is able to leverage your clusters job scheduler to submit and monitor the jobs it runs. This can be done manually, but many profiles are already available at <https://github.com/Snakemake-Profiles>. These require cookiecutter to be installed as described below.

```bash
# Using base conda

conda install cookiecutter

# Using mamba

mamba install cookiecutter
```

**NOTE: this Snakefile has some rules with explicitly specified queue names tailored for the cluster system it is devloped on. You will likely need to change this to keep your cluster admins happy.**

### Recommended - Run checks that your configuration is correct

Snakemake has inbuilt methods to do dry-runs and report the jobs it will run, it can also produce a graphical representation of its dependency graph, though the usefulness of this will decrease as your sample number increases. Any errors or warnings will be given as red text if your terminal emulator supports coloured fonts.

1.  Perform a basic dry run of your workflow

For cluster mode, replace /path/to/your/cluster/profile with the directory where your cluster specification you made above is. Also replace max_number_of_simultaneous_jobs with an integer value for how many jobs can be simultaneously submitted by Snakemake.

For standalone mode, replace the number_of_cores with an integer value for the maximum number of threads Snakemake can use.

```bash
# Cluster mode
snakemake --dry-run --profile /path/to/your/cluster/profile

# Standalone mode (not recommended for large sample counts)
snakemake --dry-run --cores number_of_cores
```

2.  Produce a DAG visulaisation of your workflow.

Replace placeholder parameters as above. Keep in mind this will get very hard to read with high sample counts.

```bash
snakemake --dag  | dot -Tpdf > dag.pdf
```

### Perform your Snakemake run

If everything passed above, you are ready to run your analysis. Keep in mind your Snakemake process MUST keep running whilst all your jobs run, for this reason if you are remote accessing a cluster system I recommend using a terminal multiplexer such as GNU Screen or tmux to keep your session active even if your connection goes down. The Snakemake process must also be able to run job submissions (such as sbatch in SLURM) and query job status (such as sacct in SLURM), some cluster implementations will allow this within a scheduled job, others will not, please test your system first.

For cluster mode, replace /path/to/your/cluster/profile with the directory where your cluster specification you made above is. Also replace max_number_of_simultaneous_jobs with an integer value for how many jobs can be simultaneously submitted by Snakemake. In cluster mode you can force a rule to override the default queue by adding the below to your rule.

```
    resources:
        partition="partition"
```

Some rules have explicit memory limits set in the resources sections, you may need to change these depending on your input files or your cluster specification.

For standalone mode, replace the number_of_cores with an integer value for the maximum number of threads Snakemake can use.

```bash
# Via sbatch, only if you can sbatch and sacct from worker nodes
sbatch /path/to/submit_snakemake.sh /path/to/profile

# Cluster mode
snakemake --profile /path/to/your/cluster/profile

# Standalone mode (not recommended for large sample counts)
snakemake --use-conda --cores number_of_cores
```

If your Snakemake process does crash/fail/is killed, don't worry, it can resume partway through the workflow without any change to the execution command.

The first run will take longer than future runs as the conda environments are created prior to running the workflow

Snakemake does have an option to remove all files created by a workflow, similar to make clean from GNU make. This can be useful if you hit an error and are concerned that it may have written an incorrect result file. Most of these will be caught by Snakemake, but this command is included below if needed. If you're running on a cluster, ensure all submitted jobs have finished before running this command.

```bash
snakemake --delete-all-output --cores 1
```
