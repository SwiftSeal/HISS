rule plot:
    input:
        "results/AgRenSeqResult.txt"
    output:
        filtered="results/filtered_contigs.txt",
        plot="images/AgRenSeq_plot.png"
    params:
        assoc_threshold=config.get("assoc_threshold", 25),
        title=config["assembly_title"]
    log:
        "logs/plot/plot.log"
    conda:
        "../envs/plot.yaml"
    threads:
        1
    resources:
        mem_mb=1000,
        partition="short"
    shell:
        "Rscript --vanilla workflow/scripts/plot.R {input} {params.assoc_threshold} {params.title} {output.filtered} {output.plot} 2> {log}"
