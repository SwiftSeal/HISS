rule blast:
    input:
        subject=config["reference"],
        query=config["assembly"]
    output:
        "results/blast/blast_sorted.txt",
        temp(multiext("results/blast/blast", ".ndb", ".nhr", ".nin", ".njs", ".not", ".nsq", ".ntf", ".nto"))
    threads:
        16
    conda:
        "../envs/blast.yaml"
    resources:
        mem_mb=4000,
        partition="short"
    shell:
        """
        makeblastdb -in {input.subject} -dbtype nucl -out "results/blast/blast"
        blastn -query {input.query} -db "results/blast/blast" -outfmt 6 -num_threads 16 | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 --merge > {output[0]}
        """
