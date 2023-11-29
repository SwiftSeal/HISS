rule run_association:
    input:
        matrix="results/output_matrix.txt",
        phenotype="results/phenotype.txt",
        nlr="results/{reference}_output.nlr.txt",
	    assembly=get_reference
    output:
        "results/{reference}_AgRenSeqResult.txt"
    threads:
        2
    resources:
        mem_mb=14000
    conda:
        "../envs/java.yaml"
    shell:
        """
        java -jar ../utils/AgRenSeq_RunAssociation.jar -i {input.matrix} -n {input.nlr} -p {input.phenotype} -a {input.assembly} -o {output}
        """
