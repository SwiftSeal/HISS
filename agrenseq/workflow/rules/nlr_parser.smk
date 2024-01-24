rule nlr_parser:
    input:
        assembly = get_reference
    output:
        "results/{reference}_output.nlr.txt"
    threads:
        2
    resources:
        mem_mb = 2000
    conda:
        "../envs/meme.yaml"
    log:
        "logs/nlr_parser/{reference}.log"
    shell:
        """
        java -jar ../utils/NLR-Parser3.jar -t {threads} -y $(which mast) -x ../utils/meme.xml -i {input} -o {output} 2> {log}
        """
