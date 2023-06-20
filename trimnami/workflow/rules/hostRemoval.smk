
rule host_removal_mapping_paired:
    """Map reads to host and return unmapped reads"""
    input:
        r1 = os.path.join(dir.temp,"{dir}","{sample}.paired.R1.fastq.gz"),
        r2 = os.path.join(dir.temp,"{dir}","{sample}.paired.R2.fastq.gz"),
        host = config.args.host
    output:
        r1=temp(os.path.join(dir.temp,"{dir}","{sample}_R1.unmapped.fastq")),
        r2=temp(os.path.join(dir.temp,"{dir}","{sample}_R2.unmapped.fastq")),
        s=temp(os.path.join(dir.temp,"{dir}","{sample}_R1.unmapped.singletons.fastq")),
        o=temp(os.path.join(dir.temp,"{dir}","{sample}_R1.other.singletons.fastq"))
    benchmark:
        os.path.join(dir.bench,"host_removal_mapping.{dir}.{sample}.txt")
    log:
        mm=os.path.join(dir.log,"host_removal_mapping.{dir}.{sample}.minimap.log"),
        sv=os.path.join(dir.log,"host_removal_mapping.{dir}.{sample}.samtoolsView.log"),
        fq=os.path.join(dir.log,"host_removal_mapping.{dir}.{sample}.samtoolsFastq.log")
    resources:
        mem_mb=config.resources.job.mem,
        time=config.resources.job.time
    threads:
        config.resources.job.cpu
    conda:
        os.path.join(dir.env,"minimap2.yaml")
    shell:
        """
        minimap2 -ax sr -t {threads} --secondary=no {input.host} {input.r1} {input.r2} 2> {log.mm} \
            | samtools view -f 4 -h 2> {log.sv} \
            | samtools fastq -NO -1 {output.r1} -2 {output.r2} -0 {output.o} -s {output.s} 2> {log.fq}
        rm {log.mm} {log.sv} {log.fq}
        """