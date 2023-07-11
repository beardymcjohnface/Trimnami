rule index_host_genome:
    """Pre-index the host genome for mapping with minimap2"""
    input:
        lambda wildcards: config.args.host if config.args.host else ""
    output:
        config.args.hostIndex
    params:
        params = config.qc.minimapIndex
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"minimap2.yaml")
    benchmark:
        os.path.join(dir.bench,"index_host_genome.txt")
    log:
        os.path.join(dir.log,"index_host_genome.log")
    shell:
        """minimap2 -t {threads} {params} -d {output} {input} &> {log}"""


rule host_removal_mapping_paired:
    """Map reads to host and return unmapped reads"""
    input:
        r1=lambda wildcards: samples.reads[wildcards.sample]["R1"],
        r2=lambda wildcards: samples.reads[wildcards.sample]["R2"],
        host=lambda wildcards: config.args.hostIndex if config.args.host else ""
    output:
        r1=temp(os.path.join(dir.temp,"{sample}.host_rm.paired.R1.fastq.gz")),
        r2=temp(os.path.join(dir.temp,"{sample}.host_rm.paired.R2.fastq.gz")),
        s=temp(os.path.join(dir.temp,"{sample}.host_rm.paired.S.fastq.gz")),
        o=temp(os.path.join(dir.temp,"{sample}.host_rm.paired.O.fastq.gz")),
    params:
        compression=config.qc.compression
    benchmark:
        os.path.join(dir.bench,"host_removal_mapping.{sample}.txt")
    log:
        mm=os.path.join(dir.log,"host_removal_mapping.{sample}.minimap.log"),
        sv=os.path.join(dir.log,"host_removal_mapping.{sample}.samtoolsView.log"),
        fq=os.path.join(dir.log,"host_removal_mapping.{sample}.samtoolsFastq.log"),
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"minimap2.yaml")
    shell:
        """
        minimap2 -ax sr -t {threads} --secondary=no {input.host} {input.r1} {input.r2} 2> {log.mm} \
            | samtools view -f 4 -h 2> {log.sv} \
            | samtools fastq -NO -c {params.compression} -1 {output.r1} -2 {output.r2} -0 {output.o} -s {output.s} 2> {log.fq}
        cat {output.o} >> {output.s}
        """


rule host_removal_mapping_single:
    """Map reads to host and return unmapped reads"""
    input:
        r1=lambda wildcards: samples.reads[wildcards.sample]["R1"],
        host=lambda wildcards: config.args.hostIndex if config.args.host else ""
    output:
        r1=temp(os.path.join(dir.temp,"{sample}.host_rm.single.fastq.gz")),
        s=temp(os.path.join(dir.temp,"{sample}.host_rm.single.S.fastq.gz")),
        o=temp(os.path.join(dir.temp,"{sample}.host_rm.single.O.fastq.gz")),
    params:
        compression=config.qc.compression,
        minimap_mode=config.args.minimap
    benchmark:
        os.path.join(dir.bench,"host_removal_mapping.{sample}.txt")
    log:
        mm=os.path.join(dir.log,"host_removal_mapping.{sample}.minimap.log"),
        sv=os.path.join(dir.log,"host_removal_mapping.{sample}.samtoolsView.log"),
        fq=os.path.join(dir.log,"host_removal_mapping.{sample}.samtoolsFastq.log")
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"minimap2.yaml")
    shell:
        """
        minimap2 -ax {params.minimap_mode} -t {threads} --secondary=no {input.host} {input.r1} 2> {log.mm} \
            | samtools view -f 4 -h 2> {log.sv} \
            | samtools fastq -nO -c {params.compression} -o {output.r1} -0 {output.o} -s {output.s} 2> {log.fq}
        cat {output.o} {output.s} >> {output.r1}
        """


rule skip_host_rm_paired:
    """Skip host removal of paired reads"""
    input:
        r1 = lambda wildcards: samples.reads[wildcards.sample]["R1"],
        r2 = lambda wildcards: samples.reads[wildcards.sample]["R2"],
    output:
        r1 = temp(os.path.join(dir.temp,"{sample}.paired.R1.fastq.gz")),
        r2 = temp(os.path.join(dir.temp,"{sample}.paired.R2.fastq.gz")),
        s = temp(os.path.join(dir.temp,"{sample}.paired.S.fastq.gz")),
    params:
        is_paired = True
    localrule:
        True
    log:
        stderr = os.path.join(dir.log, "skip_host_rm_pair.{sample}.err"),
        stdout = os.path.join(dir.log, "skip_host_rm_pair.{sample}.out")
    script:
        os.path.join(dir.scripts, "skipHostRm.py")


rule skip_host_rm_single:
    """Skip host removal of paired reads"""
    input:
        r1 = lambda wildcards: samples.reads[wildcards.sample]["R1"],
    output:
        r1 = temp(os.path.join(dir.temp,"{sample}.single.fastq.gz")),
    params:
        is_paired = False
    localrule:
        True
    script:
        os.path.join(dir.scripts, "skipHostRm.py")
