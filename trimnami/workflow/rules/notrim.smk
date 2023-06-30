rule notrim_paired_end:
    """Skip read trimming for paired reads"""
    input:
        r1=os.path.join(dir.temp,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.temp,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.temp,"{file}.S.fastq.gz"),
    output:
        r1=os.path.join(dir.notrim,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.notrim,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.notrim,"{file}.S.fastq.gz"),
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
        r1=os.path.join(dir.temp,"{file}.single.fastq.gz"),
    output:
        r1=os.path.join(dir.notrim,"{file}.single.fastq.gz"),
    localrule:
        True
    shell:
        """
        ln {input.r1} {output.r1}
        """
