rule nlr_parser:
    input:
        config["assembly"]
    output:
        "results/output.nlr.txt"
    log:
        "logs/nlr_parser/nlr_parser.log"
    threads:
        4
    resources:
        mem_mb=4000,
        partition="short"
    conda:
        "../envs/meme.yaml"
    shell:
        "java -jar workflow/scripts/NLR-Parser.jar -t 4 -y $(which mast) -x workflow/scripts/meme.xml -i {input} -o {output} 2> {log}"

