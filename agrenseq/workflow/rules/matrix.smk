rule matrix:
    input:
        "results/accessions.txt"
    output:
        temp("results/output_matrix.txt")
    log:
        "logs/jellyfish/matrix.log"
    threads:
        1
    resources:
        mem_mb=64000,
        partition="short"
    conda:
        "../envs/meme.yaml"
    shell:
        "java -jar ../utils/AgRenSeq_CreatePresenceMatrix.jar -i {input} -o {output} -t 3 -n 10 2> {log}"
