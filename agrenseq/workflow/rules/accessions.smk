from pathlib import Path
rule accessions:
    input:
        expand("results/jellyfish/{sample}.dump", sample = read_scores["sample"])
    output:
        temp("results/accessions.txt")
    threads:
        1
    resources:
        mem_mb=1000,
        partition="short"
    run:
        for f in input:
            with open(output[0], "a") as out:
                out.write(f"{Path(f).stem}\t{f}\n")
