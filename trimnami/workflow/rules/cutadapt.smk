@target_rule
rule cutadapt:
    input:
        targets["output"]["cutadapt"],


rule cutadapt_paired_end:
    """Skip read trimming for paired reads"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2=lambda wildcards: samples["reads"][wildcards.sample]["R2"],
        adapters=os.path.join(dir["db"],"IlluminaAdapters.fa")
    output:
        r1=temp(os.path.join(dir["cutadapt"],"{sample}_R1.fasta")),
        r2=temp(os.path.join(dir["cutadapt"],"{sample}_R2.fasta")),
        s=temp(os.path.join(dir["cutadapt"],"{sample}_RS.fasta")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    params:
        s = lambda wildcards: samples["reads"][wildcards.sample]["S"],
        params = config["qc"]["cutadapt"]
    conda:
        os.path.join(dir["env"],"cutadapt.yaml")
    benchmark:
        os.path.join(dir["bench"],"cutadapt.{sample}.txt")
    log:
        os.path.join(dir["log"],"cutadapt.{sample}.log")
    shell:
        ("cutadapt "
            "--cores {threads} "
            "{params.params} "
            "-b file:{input.adapters} "
            "-B file:{input.adapters} "
            "-o {output.r1} "
            "-p {output.r2} "
            "--fasta "
            "{input.r1} "
            "{input.r2} "
            "&> {log}; "
        "if [[ -s {params.s} ]]; then "
            "cutadapt "
                "--cores {threads} "
                "{params.params} "
                "-b {input.adapters} "
                "-o {output.s} "
                "{params.s} "
                "&> {log}; "
        "else "
            "touch {output.s}; "
        "fi ")


rule cutadapt_single_end:
    """Skip read trimming for single end"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        adapters=os.path.join(dir["db"],"IlluminaAdapters.fa")
    output:
        r1=temp(os.path.join(dir["cutadapt"],"{sample}_S.fasta")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["cutadapt"]
    conda:
        os.path.join(dir["env"],"cutadapt.yaml")
    benchmark:
        os.path.join(dir["bench"],"cutadapt.{sample}.txt")
    log:
        os.path.join(dir["log"],"cutadapt.{sample}.log")
    shell:
        ("cutadapt "
            "--cores {threads} "
            "{params.params} "
            "-b file:{input.adapters} "
            "-o {output.r1} "
            "--fasta  "
            "{input.r1} "
            "&> {log}; ")


rule fasta_to_fastq:
    """Convert the fasta files to fastq files for cutadapt"""
    input:
        os.path.join(dir["cutadapt"], "{file}.fasta")
    output:
        temp(os.path.join(dir["cutadapt"],"{file}.fastq.gz"))
    params:
        compression = "-" + str(config["qc"]["compression"])
    conda:
        os.path.join(dir["env"],"seqtk.yaml")
    benchmark:
        os.path.join(dir["bench"],"fasta_to_fastq.{file}.txt")
    log:
        os.path.join(dir["log"],"fasta_to_fastq.{file}.log")
    shell:
        ("seqtk "
            "seq -F 'B' {input} "
            "| gzip {params.compression} "
            "> {output} "
            "2> {log}; ")