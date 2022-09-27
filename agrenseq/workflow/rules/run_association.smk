rule run_association:
    input:
        matrix="results/output_matrix.txt",
        phenotype="results/phenotype.txt",
        nlr="results/{reference}_output.nlr.txt",
	assembly=get_reference
    output:
        "results/{reference}_AgRenSeqResult.txt"
    log:
        "logs/{reference}_run_association.log"
    threads:
        1
    resources:
        mem_mb=16000,
        partition="short"
    conda:
        "../envs/java.yaml"
    shell:
        "java -jar ../utils/AgRenSeq_RunAssociation.jar -i {input.matrix} -n {input.nlr} -p {input.phenotype} -a {input.assembly} -o {output} 2> {log}"
