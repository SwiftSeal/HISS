rule nlr_annotator:
    input:
        assembly=get_reference
    output:
        "results/{reference}_output.nlr.txt"
    log:
        "logs/nlr_parser/{reference}_nlr_parser.log"
    threads:
        4
    resources:
        mem_mb=8000,
        partition="short"
    conda:
        "../envs/java.yaml"
    shell:
        "java -jar ../utils/NLR-Annotator-v2.1.jar -t 4 -x ../utils/mot.txt -y ../utils/store.txt -i {input.assembly} -o {output} 2> {log}"

