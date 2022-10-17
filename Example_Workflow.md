# Finding *Rx* in Potato - an example workflow

**TODO: Update file paths to reads once they're uploaded to ENA. Also add commands to pull down from ENA**

## Download required files

All files, except for the reference DM potato genome are available in this repository, simply clone down the repository to your local machine. All commands in this workflow will assume you are based in this repository, you may need to change commands if you change the structure.

Ensure you have followed the instructions in README.md to install required software

```bash
# Fetch the DM genome, this is too large to include here
cd example_inputs/agrenseq
wget http://spuddb.uga.edu/data/PGSC_DM_v4.03_pseudomolecules.fasta.zip
unzip PGSC_DM_v4.03_pseudomolecules.fasta.zip
```

## Perform SMRT-RenSeq assembly

Depending on your system, you may be able to wrap these commands into a job with eg. sbatch

```bash
# Copy files to SMRT-RenSeq assembly directory
cd ../../smrtrenseq_assembly
cp ../example_inputs/smrtrenseq_assembly/* config/.
```
