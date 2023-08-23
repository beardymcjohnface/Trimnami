@target_rule
rule filtlong:
    input:
        targets["output"]["filtlong"],


rule filtlong_single:
    input:
        i=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        o=temp(os.path.join(dir["filtlong"],"{sample}_S.fastq.gz")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"], "filtlong.yaml")
    params:
        params=config["qc"]["filtlong"]
    benchmark:
        os.path.join(dir["bench"],"filtlong_single.{sample}.txt")
    log:
        os.path.join(dir["log"], "filtlong_single.{sample}.log")
    shell:
        ("filtlong {params.params} {input.i} 2> {log} "
            "| gzip -1 "
            "> {output.o}; ")


rule filtlong_paried:
    """You probably don't want to be running filtlong on paired reads"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2=lambda wildcards: samples["reads"][wildcards.sample]["R2"],
    output:
        r1=temp(os.path.join(dir["filtlong"],"{sample}_R1.fastq.gz")),
        r2=temp(os.path.join(dir["filtlong"],"{sample}_R2.fastq.gz")),
        s=temp(os.path.join(dir["filtlong"],"{sample}_RS.fastq.gz")),
    params:
        s = lambda wildcards: samples["reads"][wildcards.sample]["S"],
        params=config["qc"]["filtlong"]
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"], "filtlong.yaml")
    benchmark:
        os.path.join(dir["bench"],"filtlong_paried.{sample}.txt")
    log:
        os.path.join(dir["log"], "filtlong_paried.{sample}.log")
    shell:
        ("filtlong {params.params} {input.r1} 2> {log}"
            "| gzip -1 "
            "> {output.r1}; "
        "filtlong {params.params} {input.r2} 2> {log}"
            "| gzip -1 "
            "> {output.r2}; "
        "if [[ -s {params.s} ]]; "
        "then "
            "filtlong {params.params} {params.s} 2> {log}"
                "| gzip -1 "
                "> {params.s}; "
        "else "
            "touch {output.s}; "
        "fi ")
