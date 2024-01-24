<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/HISSlogo_light.png">
  <img alt="Logo" src="assets/HISSlogo_dark.png">
</picture>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7271098.svg)](https://doi.org/10.5281/zenodo.7271098)
[![DOI:10.1186/s12859-023-05335-88](http://img.shields.io/badge/DOI-10.1186/s12859.023.05335.8-B31B1b.svg)](https://doi.org/10.1186/s12859-023-05335-8)

# Automated RenSeq workflows with Snakemake

## Why Snakemake?

Snakemake is a workflow manager that uses python syntax. In short, it allows for an entire workflow that traditionally would be separated into multiple bash scripts to be run with a single command.
It will also intelligently handle resources, job execution order and monitoring for errors to improve efficiency.
Documentation on Snakemake is available here: <https://snakemake.readthedocs.io/en/stable/>

## Running the Snakemake workflow

### Preparation steps

There are a few things you need to set up prior to running the workflow with Snakemake.

1.  Install either Anaconda or Miniconda, Miniconda is more lightweight so we recommend this option. <https://docs.conda.io/en/latest/miniconda.html>

    We also recommend installing the alternative dependency resolver mamba, it's the default for Snakemake and is far quicker than base conda <https://anaconda.org/conda-forge/mamba>. Please note some users have reported issues with mamba, if you experience these please try reverting to the base conda resolver. You can force the workflow to use the base resolver with the --conda-frontend conda option.

```bash
conda install mamba
```

You will also need to install pandas and biopython

```bash
# With mamba
mamba install pandas
mamba install biopython

# With base conda
conda install pandas
conda install biopython
```

2.  Install Snakemake into your base conda environment

```bash
# If mamba has been installed
mamba install snakemake

# If using only base conda
conda install snakemake
```

3.  If running in a cluster environment, install the executor and create a profile

Snakemake is able to leverage your clusters job scheduler to submit and monitor the jobs it runs. This can be done manually, but many profiles are already available at <https://github.com/Snakemake-Profiles>. These require cookiecutter to be installed as described below. Ensure that your created profile defaults to use conda to leverage the conda yamls provided by the workflow. Ensure you also set a sensible maximum number of simultaneous jobs. The specific value will depend on your clusters capacity.

As of Snakemake v8.0, you also need to install the executor for your job scheduler, you can find these at <https://snakemake.github.io/snakemake-plugin-catalog/index.html>. The test environment also had the snakemake-executor-plugin-cluster-generic installed alongside a specific plugin for the job scheduler.

```bash
# Using mamba

mamba install cookiecutter


# Using base conda

conda install cookiecutter

# Then follow the instructions for the relevant executors and profiles
```

**NOTE: these Snakefiles have some rules with explicitly specified queue names tailored for the cluster system it was developed on.
You will likely need to change this for optimal resource usage and to comply with your local queue policies.**

You may also need to modify your profile, the test environment utilised slurm and required the following changes to the slurm profile to provide compatability with snakemake v8.0 and above

```
cluster: "slurm-submit.py" changed to cluster-generic-submit-cmd: "slurm-submit.py"
cluster-cancel: "scancel" changed to cluster-generic-cancel-cmd: "scancel"
cluster-status: "slurm-status.py" changed to cluster-generic-status-cmd: "slurm-status.py"
cluster-sidecar: "slurm-sidecar.py" changed to cluster-generic-sidecar-cmd; "slurm-sidecar.py"
```

### Recommended - Run checks that your configuration is correct

Snakemake has inbuilt methods to do dry-runs and report the jobs it will run, it can also produce a graphical representation of its dependency graph, though the usefulness of this will decrease as your sample number increases.
Any errors or warnings will be given as red text if your terminal emulator supports coloured fonts.

1.  Perform a basic dry run of your workflow

For cluster mode, replace /path/to/your/cluster/profile with the directory where your cluster specification you made above is. Also replace name_of_installed_executor with the executor you have installed above. You may also wish to set default resources, such as default partitions. This is done with the --default-resources option. See the Snakemake documentation for more details on specific schedulers.

For standalone mode, replace the number_of_cores with an integer value for the maximum number of threads Snakemake can use.

```bash
# Cluster mode
snakemake --dry-run --executor name_of_installed_executor --profile /path/to/your/cluster/profile

# Standalone mode (not recommended for large sample counts)
snakemake --dry-run --cores number_of_cores
```

2.  Produce a DAG visualisation of your workflow.

Replace placeholder parameters as above.
Keep in mind this will get very hard to read with high sample counts.

```bash
snakemake --dag  | dot -Tpdf > dag.pdf
```

### Perform your Snakemake run

If everything passed above, you are ready to run your analysis.
Keep in mind your Snakemake process MUST keep running whilst all your jobs run, for this reason if you are remote accessing a cluster system we recommend using a terminal multiplexer such as GNU Screen or tmux to keep your session active even if your connection goes down.
The Snakemake process must also be able to run job submissions (such as sbatch in SLURM) and query job status (such as sacct in SLURM), some cluster implementations will allow this within a scheduled job, others will not, please test your system first or contact your local admin.

For cluster mode, replace /path/to/your/cluster/profile with the directory where your cluster specification you made above is. Also replace name_of_installed_executor with the executor you have installed above. You may also wish to set default resources, such as default partitions. This is done with the --default-resources option. See the Snakemake documentation for more details on specific schedulers.
In cluster mode you can force a rule to override the default queue by adding the below to your rule.

```
    resources:
        slurm_partition="partition"
```

Some rules have explicit memory limits set in the resources sections, you may need to change these depending on your input files or your cluster specification.

For standalone mode, replace the number_of_cores with an integer value for the maximum number of threads Snakemake can use.

You may be able to wrap the snakemake command into a shell script if your system allows submission of jobs from within jobs.

Some users have reported that the default mamba frontend in snakemake can cause environments to fail to build. If you experience this, please add the --conda-frontend conda argument to your snakemake command.

```bash
# Cluster mode
snakemake --executor name_of_installed_executor --profile /path/to/your/cluster/profile

# Standalone mode (not recommended for large sample counts)
snakemake --use-conda --cores number_of_cores
```

If your Snakemake process does crash/fail/is killed, don't worry, it can resume partway through the workflow without any change to the execution command.

The first run will take longer than future runs as the conda environments are created prior to running the workflow.

Snakemake does have an option to remove all files created by a workflow, similar to make clean from GNU make.
This can be useful if you hit an error and are concerned that it may have written an incorrect result file.
Most of these will be caught by Snakemake, but this command is included below if needed.
If you're running on a cluster, ensure all submitted jobs have finished before running this command.

```bash
snakemake --delete-all-output --cores 1
```
