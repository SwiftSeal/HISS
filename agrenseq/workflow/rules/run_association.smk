rule run_association:
    input:
        matrix="results/output_matrix.txt",
        phenotype="results/phenotype.txt",
        nlr="results/output.nlr.txt",
        assembly=config["assembly"]
    output:
        "results/AgRenSeqResult.txt"
    log:
        "logs/jellyfish/run_association.log"
    threads:
        1
    resources:
        mem_mb=16000,
        partition="short"
    conda:
        "../envs/java.yaml"
    shell:
        "java -jar ../utils/AgRenSeq_RunAssociation.jar -i {input.matrix} -n {input.nlr} -p {input.phenotype} -a {input.assembly} -o {output} 2> {log}"
