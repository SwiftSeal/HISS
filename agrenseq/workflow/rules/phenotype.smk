rule phenotype:
    input:
        config["read_scores"]
    output:
        temp("results/phenotype.txt")
    resources:
        mem_mb = 1000
    log:
        "logs/phenotype/phenotype.log"
    shell:
        """
        tail -n +2 {input} | cut --complement -f2,3 1> {output} 2> {log}
        """
