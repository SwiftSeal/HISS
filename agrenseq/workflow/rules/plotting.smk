rule sizes:
    input:
        blast_genome = config["blast_genome"]
    output:
        genome_size = "results/genome_sizes.txt"
    conda:
        "../envs/plot.yaml"
    resources:
        mem_mb = 1000
    shell:
        """
        bioawk -c fastx '{{ print $name, length($seq) }}' {input.blast_genome} > {output.genome_size}
        """

rule blast_plot:
    input:
        blast_genome = config["blast_genome"],
        blast_result = "results/blast/{reference}_blast_sorted.txt",
        filtered = "results/{reference}_filtered_contigs.txt",
        genome_size = "results/genome_sizes.txt"
    output:
        plot = "images/{reference}_blast_plot.png"
    conda:
        "../envs/plot.yaml"
    resources:
        mem_mb = 1000
    shell:
        """
        Rscript --vanilla workflow/scripts/blast_plot.R {input.genome_size} {input.blast_result} {input.filtered} {wildcards.reference} {output.plot}
        """

rule plot:
    input:
        "results/{reference}_AgRenSeqResult.txt"
    output:
        filtered = "results/{reference}_filtered_contigs.txt",
        plot = "images/{reference}_AgRenSeq_plot.png"
    params:
        assoc_threshold = config.get("assoc_threshold", 25),
    conda:
        "../envs/plot.yaml"
    resources:
        mem_mb = 1000
    shell:
        """
        Rscript --vanilla workflow/scripts/plot.R {input} {params.assoc_threshold} {wildcards.reference} {output.filtered} {output.plot}
        """
