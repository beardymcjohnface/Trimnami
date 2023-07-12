rule filtlong:
    input:
        i=os.path.join(dir.temp,"{file}.single.fastq.gz"),
    output:
        o=os.path.join(dir.nanopore,"{file}.single.fastq.gz"),
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env, "filtlong.yaml")
    params:
        params=config.qc.nanopore.filtlong
    log:
        os.path.join(dir.log, "filtlong_{file}.log")
    shell:
        """
            export LC_ALL=en_US.UTF-8
            filtlong {params.params} {input.i} | gzip -1 > {output.o} 2> {log}
        """


rule nanopore_paired:
    """This rule should never be run"""
    input:
        r1=os.path.join(dir.temp,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.temp,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.temp,"{file}.S.fastq.gz"),
    output:
        r1=os.path.join(dir.nanopore,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.nanopore,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.nanopore,"{file}.S.fastq.gz"),
    localrule:
        True
    shell:
        """
        cp {input.r1} {output.r1}
        cp {input.r2} {output.r2}
        cp {input.s} {output.s}
        """