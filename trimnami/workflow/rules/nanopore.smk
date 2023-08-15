@target_rule
rule nanopore:
    input:
        targets["nanopore"],
        targets["reports"]


rule filtlong:
    input:
        i=os.path.join(dir["temp"],"{sample}_single{host}.fastq.gz"),
    output:
        o=os.path.join(dir["nanopore"],"{sample}_single{host}.fastq.gz"),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"], "filtlong.yaml")
    params:
        params=config["qc"]["nanopore"]["filtlong"]
    benchmark:
        os.path.join(dir["bench"],"filtlong_{sample}{host}.txt")
    log:
        os.path.join(dir["log"], "filtlong_{sample}{host}.log")
    shell:
        """
        filtlong {params.params} {input.i} | gzip -1 > {output.o} 2> {log}
        """


rule nanopore_paired:
    """This rule should never be run"""
    input:
        r1=os.path.join(dir["temp"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["temp"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["temp"],"{sample}_S{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["nanopore"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["nanopore"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["nanopore"],"{sample}_S{host}.fastq.gz"),
    localrule:
        True
    shell:
        """
        ln {input.r1} {output.r1}
        ln {input.r2} {output.r2}
        ln {input.s} {output.s}
        """