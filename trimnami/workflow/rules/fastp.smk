rule fastp_paired_end:
    """Read trimming with fastp for paired reads"""
    input:
        r1=lambda wildcards: samples.reads[wildcards.sample]["R1"],
        r2=lambda wildcards: samples.reads[wildcards.sample]["R2"],
    output:
        r1=temp(os.path.join(dir.temp,"fastp","{sample}.paired.R1.fastq.gz")),
        r2=temp(os.path.join(dir.temp,"fastp","{sample}.paired.R2.fastq.gz")),
        stats=os.path.join(dir.temp,"fastp","{sample}.stats.json"),
        html=temp(os.path.join(dir.temp,"fastp","{sample}.stats.html"))
    benchmark:
        os.path.join(dir.bench,"fastp.{sample}.txt")
    log:
        os.path.join(dir.log,"fastp.{sample}.log")
    resources:
        mem_mb=config.resources.job.mem,
        time=config.resources.job.time
    threads:
        config.resources.job.cpu
    conda:
        os.path.join(dir.env,"fastp.yaml")
    params:
        fastp=config.fastp,
        compression=config.qc.compression
    shell:
        """
        fastp -i {input.r1} -I {input.r2} -o {output.r1} -O {output.r2} \
            -z {params.compression} -j {output.stats} -h {output.html} --thread {threads} \
            --detect_adapter_for_pe {params.fastp} 2> {log}
        """


rule fastp_single_end:
    """Read trimming with fastp for single end reads"""
    input:
        r1=lambda wildcards: samples.reads[wildcards.sample]["R1"],
    output:
        r1=temp(os.path.join(dir.temp,"fastp","{sample}.single.fastq.gz")),
        stats=temp(os.path.join(dir.temp,"fastp","{sample}.stats.json")),
        html=temp(os.path.join(dir.temp,"fastp","{sample}.stats.html"))
    benchmark:
        os.path.join(dir.bench,"fastp.{sample}.txt")
    log:
        os.path.join(dir.log,"fastp.{sample}.log")
    resources:
        mem_mb=config.resources.job.mem,
        time=config.resources.job.time
    threads:
        config.resources.job.cpu
    conda:
        os.path.join(dir.env,"fastp.yaml")
    params:
        fastp=config.fastp,
        compression=config.qc.compression
    shell:
        """
        fastp -i {input.r1} -o {output.r1} \
            -z {params.compression} -j {output.stats} -h {output.html} --thread {threads} \
            --detect_adapter_for_pe {params.fastp} 2> {log}
        """


rule skip_host_removal_fastp:
    input:
        os.path.join(dir.temp, "fastp", "{filename}")
    output:
        os.path.join(dir.fastp, "{filename}")
    localrule:
        True
    run:
        import os
        os.rename(input[0], output[0])
