from pathlib import Path
rule accessions:
    input:
        expand("results/jellyfish/{sample}.dump", sample = read_scores["sample"])
    output:
        temp("results/accessions.txt")
    resources:
        mem_mb = 1000
    log:
        "logs/accessions/{sample}.log"
    run:
        import logging
        logging.basicConfig(filename=log, encoding='utf-8', level=logging.DEBUG)
        for f in input:
            with open(output[0], "a") as out:
                out.write(f"{Path(f).stem}\t{f}\n")
