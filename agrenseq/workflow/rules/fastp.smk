rule fastp:
    input:
        get_reads
    output:
        R1=temp("results/fastp/{sample}.R1.fastq.gz"),
        R2=temp("results/fastp/{sample}.R2.fastq.gz"),
        json="results/fastp/{sample}.json"
    threads:
        4
    resources:
        mem_mb=4000,
        partition="short"
    conda:
        "../envs/fastp.yaml"
    shell:
        """
        fastp -i {input}[0] -I {input}[1] -o {output.R1} -O {output.R2} -j {output.json} -h /dev/null
        """
