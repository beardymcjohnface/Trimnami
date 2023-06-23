rule filtlong:
    input:
        i=os.path.join(dir.temp,"{file}.single.fastq.gz"),
    output:
        o=temp(os.path.join(dir.temp,"{file}.fl.single.fastq.gz")),
    resources:
        mem_mb=config.resources.job.mem,
        time=config.resources.job.time
    threads:
        config.resources.job.cpu
    conda:
        os.path.join(dir.env, "filtlong.yaml")
    params:
        params=config.qc.nanopore.filtlong
    log:
        os.path.join(dir.log, "filtlong_{file}.log")
    shell:
        """
            export LC_ALL=en_US.UTF-8
            filtlong {params.params} {input.i} > {output.o} 2> {log}
        """


rule rasusa:
    input:
        i=os.path.join(dir.temp,"{file}.fl.single.fastq.gz")
    output:
        o=os.path.join(dir.nanopore,"{file}.single.fastq.gz"),
    resources:
        mem_mb=config.resources.job.mem,
        time=config.resources.job.time
    threads:
        config.resources.job.cpu
    conda:
        os.path.join(dir.env, "rasusa.yaml")
    params:
        params=config.qc.nanopore.rasusa
    log:
        os.path.join(dir.log, "rasusa_{file}.log")
    shell:
        """
            rasusa -i {input.i} -o {output.o} -O g {params.params} 2> {log}
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