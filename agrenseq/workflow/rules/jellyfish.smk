rule jellyfish:
    input:
        R1 = "results/fastp/{sample}.R1.fastq.gz",
        R2 = "results/fastp/{sample}.R2.fastq.gz"
    output:
        jf = temp("results/jellyfish/{sample}.jf"),
        dump = "results/jellyfish/{sample}.dump"
    threads:
        2
    resources:
        mem_mb = 13000
    conda:
        "../envs/jellyfish.yaml"
    log:
        "logs/jellyfish/{sample}.log"
    shell:
        """
        zcat {input.R1} {input.R2} | jellyfish count /dev/fd/0 -C -m 51 -s 1G -t {threads} -o {output.jf} 2> {log}
        jellyfish dump -L 10 -ct {output.jf} 1> {output.dump} 2>> {log}
        """
