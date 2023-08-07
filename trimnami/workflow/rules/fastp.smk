@target_rule
rule fastp:
    input:
        targets["fastp"],
        targets["reports"]


rule fastp_paired_end:
    """Read trimming with fastp for paired reads"""
    input:
        r1=os.path.join(dir["temp"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["temp"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["temp"],"{sample}_S{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["fastp"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["fastp"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["fastp"],"{sample}_S{host}.fastq.gz"),
        s1=temp(os.path.join(dir["fastp"],"{sample}_S1{host}.fastq.gz")),
        s2=temp(os.path.join(dir["fastp"],"{sample}_S2{host}.fastq.gz")),
        stats=temp(os.path.join(dir["fastp"],"{sample}{host}.stats.json")),
        html=temp(os.path.join(dir["fastp"],"{sample}{host}.stats.html"))
    benchmark:
        os.path.join(dir["bench"],"fastp.{sample}{host}.txt")
    log:
        os.path.join(dir["log"],"fastp.{sample}{host}.log")
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"fastp.yaml")
    params:
        fastp=config["qc"]["fastp"],
        compression=config["qc"]["compression"]
    shell:
        """
        fastp \
            -i {input.r1} \
            -I {input.r2} \
            -o {output.r1} \
            -O {output.r2} \
            --unpaired1 {output.s1} \
            --unpaired2 {output.s2} \
            -z {params.compression} \
            -j {output.stats} \
            -h {output.html} \
            --thread {threads} \
            {params.fastp} \
            2> {log}
        if [[ -s {input.s} ]]
        then
            fastp \
            -i {input.s} \
            -o {output.s} \
            -z {params.compression} \
            -j {output.stats} \
            -h {output.html} \
            --thread {threads} \
            {params.fastp} \
            2> {log}
        else
            touch {output.s}
        fi
        cat {output.s1} {output.s2} >> {output.s}
        """


rule fastp_single_end:
    """Read trimming with fastp for single end reads"""
    input:
        r1=os.path.join(dir["temp"],"{sample}_single{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["fastp"],"{sample}_single{host}.fastq.gz"),
        stats=temp(os.path.join(dir["fastp"],"{sample}{host}.stats.json")),
        html=temp(os.path.join(dir["fastp"],"{sample}{host}.stats.html"))
    benchmark:
        os.path.join(dir["bench"],"fastp.{sample}{host}.txt")
    log:
        os.path.join(dir["log"],"fastp.{sample}{host}.log")
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"fastp.yaml")
    params:
        fastp=config["qc"]["fastp"],
        compression=config["qc"]["compression"]
    shell:
        """
        fastp \
            -i {input.r1} \
            -o {output.r1} \
            -z {params.compression} \
            -j {output.stats} \
            -h {output.html} \
            --thread {threads} \
            {params.fastp} \
            2> {log}
        """
