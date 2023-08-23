@target_rule
rule notrim:
    input:
        targets["output"]["notrim"],


rule notrim_paired_end:
    """Skip read trimming for paired reads"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2=lambda wildcards: samples["reads"][wildcards.sample]["R2"],
    output:
        r1=temp(os.path.join(dir["notrim"],"{sample}_R1.fastq.gz")),
        r2=temp(os.path.join(dir["notrim"],"{sample}_R2.fastq.gz")),
        s=temp(os.path.join(dir["notrim"],"{sample}_RS.fastq.gz")),
    params:
        s = lambda wildcards: samples["reads"][wildcards.sample]["S"],
        is_paired = True
    script:
        os.path.join(dir["scripts"], "copyOrGzip.py")


rule notrim_single_end:
    """Skip read trimming for single end"""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        r1=temp(os.path.join(dir["notrim"],"{sample}_S.fastq.gz")),
    params:
        is_paired = False
    script:
        os.path.join(dir["scripts"], "copyOrGzip.py")
