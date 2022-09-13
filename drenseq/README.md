# README for running dRenSeq pipeline with snakemake

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
    *   A reference fasta file of your target genes, ensure this contains regions outside the CDS too, this ensures alignments are performed correctly.  
    *   A BED file of the CDS regions of your targets  
    *   A tab delimited text file with one line per sample and the header line (use absolute file paths): sample FRead RRead  
    *   FASTA files with your adaptor sequences, the current workflow uses two files, though it should be easy to modify this if needed.  
    *   A tab delimited text file of gene groups with the name of a reference gene in the first column and a group assignment for this gene in the second column. This is used to remove gene groups from the analysis if there isn't 100% coverage of at least one gene in a group.  
    *   The envs directory, this contains yamls for all the conda environments used in the workflow. Do not create these environments now, Snakemake environments are separate from your user environments.

4.  Make modifications to the config.yaml file. This follows the yaml format of key-value pairs. Keep the keys as they are, but change the value they are paired with as explained below:

    *   Reference_Fasta - replace the quoted text with a path to your reference fasta file  
    *   CDS_Bed - replace the quoted text with a path to your reference file  
    *   scoreMinRelaxed - This paramter is passed to bowtie2 and controls mismatch rate. The penalty is -6 per mismatch, so for four mismatches in a 100bp read, the penalty is (4 * -6) / 100 = -0.24. So the flag passed to bowtie would be "L,0,-0.24". This value is the default in the example config file.
    *   samples - replace the quoted text with the path to your sample sheet.
    *   adaptor_path_1 - replace the quoted text with the path to one of your adaptor containing fasta files
    *   adaptor_path_2 - replace the quoted text with the path to the other of your adaptor containing fasta files  
    *   gene_groups - replace the quoted text with the path to your gene groups text file.
    *   ploidy - replace the quoted text with the ploidy of your organism eg. for our potato work we set ploidy to 4.
    *   ulimit - If you are using a large number of samples, you may exceed your systems soft limit for the maximum number of open files allowed (often 1,024). The workflow contains a ulimit -n command to change this for the one rule that needs it, simply set the value you want it setting to here. Keep in mind there is also a hard limit on most systems.

5.  Add java utilities to CLASSPATH, either in a profile to automatically add it on every login or manually on the command line before running snakemake if you prefer.

```bash
# In profile
export CLASSPATH=$CLASSPATH:/path/to/utils.jar

# Command line
java -classpath $CLASSPATH:/path/to/utils.jar
```

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
snakemake --dry-run --profile /path/to/your/cluster/profile --jobs max_number_of_simultaneous_jobs

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
sbatch /path/to/submit_snakemake.sh /path/to/profile max_number_of_simultaneous_jobs

# Cluster mode
snakemake --use-conda --profile /path/to/your/cluster/profile --jobs max_number_of_simultaneous_jobs

# Standalone mode (not recommended for large sample counts)
snakemake --use-conda --cores number_of_cores
```

If your Snakemake process does crash/fail/is killed, don't worry, it can resume partway through the workflow without any change to the execution command.

The first run will take longer than future runs as the conda environments are created prior to running the workflow

When running with additional samples, you may find Snakemake does not compute that changes are required if the access date on your new reads is older than that of your outputs. This can be resolved by using the core GNU utility touch on one of your sets of reads. Snakemake will now assign jobs for all your new samples.

```bash
touch Read_1.fq.gz
touch Read_2.fq.gz
```

Snakemake does have an option to remove all files created by a workflow, similar to make clean from GNU make. **This is a necessary step if you are adding new genes to your analysis.** It can also be useful if you hit an error and are concerned that it may have written an incorrect result file. Most of these will be caught by Snakemake, but this command is included below if needed. If you're running on a cluster, ensure all submitted jobs have finished before running this command.

```bash
snakemake --delete-all-output --cores 1
```

Finally, in some cases you may need to only run one round of analysis and so you may wish to remove the conda environments created by snakemake. This can be done with the following command. If you do rerun in this directory, snakemake will simply recreate the environment.

```bash
rm -rf .snakemake/conda
```
