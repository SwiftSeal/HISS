rule blast_plot:
    input:
        reference=config["reference"],
        blast="results/blast/blast_sorted.txt",
        filtered="results/filtered_contigs.txt"
    output:
        size=temp("results/size.txt"),
        plot="images/blast_plot.png"
    params:
        title=config["assembly_title"]
    log:
        "logs/blast_plot/plot.log"
    conda:
        "../envs/plot.yaml"
    threads:
        1
    resources:
        mem_mb=1000,
        partition="short"
    shell:
        """
        bioawk -c fastx '{{ print $name, length($seq) }}' {input.reference} > {output.size}
        Rscript --vanilla workflow/scripts/blast_plot.R {output.size} {input.blast} {input.filtered} {params.title} {output.plot} 2> {log}
        """
