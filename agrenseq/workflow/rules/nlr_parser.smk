rule nlr_parser:
    input:
        assembly=get_reference
    output:
        "results/{reference}_output.nlr.txt"
    threads:
        4
    resources:
        mem_mb=4000,
        partition="short"
    conda:
        "../envs/meme.yaml"
    shell:
        "java -jar ../utils/NLR-Parser3.jar -t 4 -y $(which mast) -x ../utils/meme.xml -i {input} -o {output}"
