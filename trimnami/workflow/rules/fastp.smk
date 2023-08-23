@target_rule
rule fastp:
    input:
        targets["output"]["fastp"],


rule fastp_paired_end:
    """Read trimming with fastp for paired reads"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2=lambda wildcards: samples["reads"][wildcards.sample]["R2"],
    output:
        r1=temp(os.path.join(dir["fastp"],"{sample}_R1.fastq.gz")),
        r2=temp(os.path.join(dir["fastp"],"{sample}_R2.fastq.gz")),
        s=temp(os.path.join(dir["fastp"],"{sample}_RS.fastq.gz")),
        s1=temp(os.path.join(dir["fastp"],"{sample}_S1.fastq.gz")),
        s2=temp(os.path.join(dir["fastp"],"{sample}_S2.fastq.gz")),
        stats=temp(os.path.join(dir["fastp"],"{sample}.stats.json")),
        html=temp(os.path.join(dir["fastp"],"{sample}.stats.html"))
    benchmark:
        os.path.join(dir["bench"],"fastp.{sample}.txt")
    log:
        os.path.join(dir["log"],"fastp.{sample}.log")
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
        compression=config["qc"]["compression"],
        s= lambda wildcards: samples["reads"][wildcards.sample]["S"],
    shell:
        ("fastp "
            "-i {input.r1} "
            "-I {input.r2} "
            "-o {output.r1} "
            "-O {output.r2} "
            "--unpaired1 {output.s1} "
            "--unpaired2 {output.s2} "
            "-z {params.compression} "
            "-j {output.stats} "
            "-h {output.html} "
            "--thread {threads} "
            "{params.fastp} "
            "2> {log}; "
        "if [[ -s {params.s} ]]; "
        "then "
            "fastp "
            "-i {params.s} "
            "-o {output.s} "
            "-z {params.compression} "
            "-j {output.stats} "
            "-h {output.html} "
            "--thread {threads} "
            "{params.fastp} "
            "2> {log}; "
        "else "
            "touch {output.s}; "
        "fi; "
        "cat {output.s1} {output.s2} >> {output.s}; ")


rule fastp_single_end:
    """Read trimming with fastp for single end reads"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        r1=temp(os.path.join(dir["fastp"],"{sample}_S.fastq.gz")),
        stats=temp(os.path.join(dir["fastp"],"{sample}_S.stats.json")),
        html=temp(os.path.join(dir["fastp"],"{sample}_S.stats.html"))
    benchmark:
        os.path.join(dir["bench"],"fastp.{sample}.txt")
    log:
        os.path.join(dir["log"],"fastp.{sample}.log")
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
        ("fastp "
            "-i {input.r1} "
            "-o {output.r1} "
            "-z {params.compression} "
            "-j {output.stats} "
            "-h {output.html} "
            "--thread {threads} "
            "{params.fastp} "
            "2> {log}; ")
