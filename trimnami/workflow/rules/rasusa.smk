rule rasusa_single:
    input:
        i=os.path.join(dir.out, "{dir}", "{file}.single.fastq.gz")
    output:
        o=os.path.join(dir.out, "{dir}", "{file}.single.subsampled.fastq.gz"),
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env, "rasusa.yaml")
    params:
        bases=lambda wildcards: config.args.subsample if config.args.subsample else ""
    benchmark:
        os.path.join(dir.bench, "rasusa_single.{dir}.{file}.txt")
    log:
        os.path.join(dir.log, "rasusa_single.{dir}.{file}.log")
    shell:
        """
            rasusa \
                -i {input.i} \
                -o {output.o} \
                -O g \
                --bases {params.bases} \
                2> {log}
        """


rule rasusa_paired:
    input:
        r1=os.path.join(dir.out, "{dir}", "{file}.paired.R1.fastq.gz"),
        r2=os.path.join(dir.out, "{dir}", "{file}.paired.R2.fastq.gz"),
        rs=os.path.join(dir.out, "{dir}", "{file}.paired.S.fastq.gz"),
    output:
        r1=os.path.join(dir.out, "{dir}", "{file}.paired.R1.subsampled.fastq.gz"),
        r2=os.path.join(dir.out, "{dir}", "{file}.paired.R2.subsampled.fastq.gz"),
        rs=os.path.join(dir.out, "{dir}", "{file}.paired.S.subsampled.fastq.gz"),
    resources:
        mem_mb=resources.med.mem,
        time=resources.med.time
    threads:
        resources.med.cpu
    conda:
        os.path.join(dir.env, "rasusa.yaml")
    params:
        bases=lambda wildcards: config.args.subsample if config.args.subsample else ""
    benchmark:
        os.path.join(dir.bench, "rasusa_paired.{dir}.{file}.txt")
    log:
        os.path.join(dir.log, "rasusa_paired.{dir}.{file}.log")
    shell:
        """
        rasusa \
            -i {input.r1} \
            -i {input.r2} \
            -o {output.r1} \
            -o {output.r2} \
            -O g \
            --bases {params.bases} \
            2> {log}
        
        rasusa \
            -i {input.rs} \
            -o {output.rs} \
            -O g \
            --bases {params.bases} \
            2> {log}
        """