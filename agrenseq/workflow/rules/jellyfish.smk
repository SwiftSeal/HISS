rule jellyfish:
    input:
        R1="results/fastp/{sample}.R1.fastq.gz",
        R2="results/fastp/{sample}.R2.fastq.gz"
    output:
        jf=temp("results/jellyfish/{sample}.jf"),
        dump="results/jellyfish/{sample}.dump"
    threads:
        4
    resources:
        mem_mb=16000,
        partition="short"
    conda:
        "../envs/jellyfish.yaml"
    shell:
        """
        zcat {input.R1} {input.R2} | jellyfish count /dev/fd/0 -C -m 51 -s 1G -t 4 -o {output.jf}
        jellyfish dump -L 10 -ct {output.jf} > {output.dump}
        """
