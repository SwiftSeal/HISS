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
        mem_mb=8000,
        partition="short"
    conda:
        "../envs/java.yaml"
    shell:
        "java -jar ../utils/NLR-Annotator-v2.1.jar -t 4 -x ../utils/mot.txt -y ../utils/store.txt -i {input} -o {output} 2> {log}"

