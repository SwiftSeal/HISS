rule phenotype:
    input:
        config["read_scores"]
    output:
        temp("results/phenotype.txt")
    resources:
        mem_mb=1000
    shell:
        """
        tail -n +2 {input} | cut --complement -f2,3 > {output}
        """
