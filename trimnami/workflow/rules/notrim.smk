@target_rule
rule notrim:
    input:
        targets["notrim"],
        targets["reports"]


rule notrim_paired_end:
    """Skip read trimming for paired reads"""
    input:
        r1=os.path.join(dir["temp"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["temp"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["temp"],"{sample}_S{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["notrim"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["notrim"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["notrim"],"{sample}_S{host}.fastq.gz"),
    localrule:
        True
    shell:
        """
        ln {input.r1} {output.r1}
        ln {input.r2} {output.r2}
        ln {input.s} {output.s}
        """


rule notrim_single_end:
    """Skip read trimming for single end"""
    input:
        r1=os.path.join(dir["temp"],"{sample}_single{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["notrim"],"{sample}_single{host}.fastq.gz"),
    localrule:
        True
    shell:
        """
        ln {input.r1} {output.r1}
        """
