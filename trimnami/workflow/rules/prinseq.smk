@target_rule
rule prinseq:
    input:
        targets["output"]["prinseq"],


rule prinseq_paired:
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2=lambda wildcards: samples["reads"][wildcards.sample]["R2"],
    output:
        r1=temp(os.path.join(dir["prinseq"],"{sample}_R1.fastq.gz")),
        r2=temp(os.path.join(dir["prinseq"],"{sample}_R2.fastq.gz")),
        s=temp(os.path.join(dir["prinseq"],"{sample}_RS.fastq.gz")),
        s1=temp(os.path.join(dir["prinseq"],"{sample}_S1.fastq.gz")),
        s2=temp(os.path.join(dir["prinseq"],"{sample}_S2.fastq.gz")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"prinseq.yaml")
    params:
        params = config["qc"]["prinseq"],
        s= lambda wildcards: samples["reads"][wildcards.sample]["S"],
    log:
        os.path.join(dir["log"], "prinseq.{sample}.log")
    benchmark:
        os.path.join(dir["bench"],"prinseq.{sample}.txt")
    shell:
        ("prinseq++ {params.params} "
            "-out_gz "
            "-threads {threads} "
            "-out_good {output.r1} "
            "-out_good2 {output.r2} "
            "-out_single {output.s1} "
            "-out_single2 {output.s2} "
            "-out_bad /dev/null "
            "-out_bad2 /dev/null "
            "-fastq {input.r1} "
            "-fastq2 {input.r2}  &> {log}; "
        "if [[ -s {params.s} ]]; "
        "then "
            "prinseq++ {params.params} "
                "-out_gz "
                "-threads {threads} "
                "-out_good {output.s} "
                "-out_bad /dev/null "
                "-fastq {input.r1} &> {log}; "
        "else "
            "touch {output.s}; "
        "fi; "
        "cat {output.s1} {output.s2} >> {output.s}; ")


rule prinseq_single:
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        r1=temp(os.path.join(dir["prinseq"],"{sample}_S.fastq.gz")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"prinseq.yaml")
    params:
        params = config["qc"]["prinseq"]
    log:
        os.path.join(dir["log"], "prinseq.{sample}.log")
    benchmark:
        os.path.join(dir["bench"],"prinseq.{sample}.txt")
    shell:
        ("prinseq++ {params.params} "
            "-out_gz "
            "-threads {threads} "
            "-out_good {output.r1} "
            "-out_bad /dev/null "
            "-fastq {input.r1} &> {log}; ")
