rule prinseq_paired:
    input:
        r1=os.path.join(dir.temp,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.temp,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.temp,"{file}.S.fastq.gz"),
    output:
        r1=os.path.join(dir.prinseq,"{file}.R1.fastq.gz"),
        r2=os.path.join(dir.prinseq,"{file}.R2.fastq.gz"),
        s=os.path.join(dir.prinseq,"{file}.S.fastq.gz"),
        s1=temp(os.path.join(dir.prinseq,"{file}.S1.fastq.gz")),
        s2=temp(os.path.join(dir.prinseq,"{file}.S2.fastq.gz")),
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"prinseq.yaml")
    params:
        params = config.qc.prinseq
    log:
        os.path.join(dir.log, "prinseq.{file}.log")
    benchmark:
        os.path.join(dir.bench,"prinseq.{file}.txt")
    shell:
        """
        prinseq++ {params.params} \
            -out_gz \
            -threads {threads} \
            -out_good {output.r1} \
            -out_good2 {output.r2} \
            -out_single {output.s1} \
            -out_single2 {output.s2} \
            -out_bad /dev/null \
            -out_bad2 /dev/null \
            -fastq {input.r1} \
            -fastq2 {input.r2}  &> {log}
        if [[ -s {input.s} ]]
        then
            prinseq++ {params.params} \
                -out_gz \
                -threads {threads} \
                -out_good {output.s} \
                -out_bad /dev/null \
                -fastq {input.r1} &> {log}
        else
            touch {output.s}
        fi
        cat {output.s1} {output.s2} >> {output.s}
        """


rule prinseq_single:
    input:
        r1=os.path.join(dir.temp,"{file}.single.fastq.gz"),
    output:
        r1=os.path.join(dir.prinseq,"{file}.single.fastq.gz"),
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env,"prinseq.yaml")
    params:
        params = config.qc.prinseq
    log:
        os.path.join(dir.log, "prinseq.{file}.log")
    benchmark:
        os.path.join(dir.bench,"prinseq.{file}.txt")
    shell:
        """
        prinseq++ {params.params} \
            -out_gz \
            -threads {threads} \
            -out_good {output.r1} \
            -out_bad /dev/null \
            -fastq {input.r1} &> {log}
        """
