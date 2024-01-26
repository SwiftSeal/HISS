rule matrix:
    input:
        "results/accessions.txt"
    output:
        temp("results/output_matrix.txt")
    threads:
        2
    resources:
        mem_mb = 30000
    conda:
        "../envs/java.yaml"
    log:
        "logs/matrix/create_presence_matrix.log"
    shell:
        """
        java -jar ../utils/AgRenSeq_CreatePresenceMatrix.jar -i {input} -o {output} -t 3 -n 10 2> {log}
        """
