# Finding *Rx* in Potato - an example workflow

## Gather required files

All files, except for the reference DM potato genome are available in this repository, simply clone down the repository to your local machine. All commands in this workflow will assume you are based in this repository, you may need to change commands if you change the structure.

```bash
# Fetch the DM genome, this is too large to include here
cd example_inputs/agrenseq
wget http://spuddb.uga.edu/data/PGSC_DM_v4.03_pseudomolecules.fasta.zip
unzip PGSC_DM_v4.03_pseudomolecules.fasta.zip
```
