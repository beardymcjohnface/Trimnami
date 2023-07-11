rule fastp_paired_end:
    """Read trimming with fastp for paired reads"""
    input:
        r1=os.path.join(dir.temp,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.temp,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.temp,"{file}.S.fastq.gz"),
    output:
        r1=os.path.join(dir.fastp,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.fastp,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.fastp,"{file}.S.fastq.gz"),
        s1=temp(os.path.join(dir.fastp,"{file}.S1.fastq.gz")),
        s2=temp(os.path.join(dir.fastp,"{file}.S2.fastq.gz")),
        stats=temp(os.path.join(dir.fastp,"{file}.stats.json")),
        html=temp(os.path.join(dir.fastp,"{file}.stats.html"))
    benchmark:
        os.path.join(dir.bench,"fastp.{file}.txt")
    log:
        os.path.join(dir.log,"fastp.{file}.log")
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"fastp.yaml")
    params:
        fastp=config.fastp,
        compression=config.qc.compression
    shell:
        """
        fastp \
            -i {input.r1} \
            -I {input.r2} \
            -o {output.r1} \
            -O {output.r2} \
            --unpaired1 {output.s1} \
            --unpaired2 {output.s2} \
            -z {params.compression} \
            -j {output.stats} \
            -h {output.html} \
            --thread {threads} \
            {params.fastp} \
            2> {log}
        if [[ -s {input.s} ]]
        then
            fastp \
            -i {input.s} \
            -o {output.s} \
            -z {params.compression} \
            -j {output.stats} \
            -h {output.html} \
            --thread {threads} \
            {params.fastp} \
            2> {log}
        else
            touch {output.s}
        fi
        cat {output.s1} {output.s2} >> {output.s}
        """


rule fastp_single_end:
    """Read trimming with fastp for single end reads"""
    input:
        r1=os.path.join(dir.temp,"{file}.single.fastq.gz"),
    output:
        r1=os.path.join(dir.fastp,"{file}.single.fastq.gz"),
        stats=temp(os.path.join(dir.fastp,"{file}.stats.json")),
        html=temp(os.path.join(dir.fastp,"{file}.stats.html"))
    benchmark:
        os.path.join(dir.bench,"fastp.{file}.txt")
    log:
        os.path.join(dir.log,"fastp.{file}.log")
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"fastp.yaml")
    params:
        fastp=config.fastp,
        compression=config.qc.compression
    shell:
        """
        fastp \
            -i {input.r1} \
            -o {output.r1} \
            -z {params.compression} \
            -j {output.stats} \
            -h {output.html} \
            --thread {threads} \
            {params.fastp} \
            2> {log}
        """
