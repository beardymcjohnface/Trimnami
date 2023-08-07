@target_rule
rule prinseq:
    input:
        targets["prinseq"],
        targets["reports"]


rule prinseq_paired:
    input:
        r1=os.path.join(dir["temp"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["temp"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["temp"],"{sample}_S{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["prinseq"],"{sample}_R1{host}.fastq.gz"),
        r2=os.path.join(dir["prinseq"],"{sample}_R2{host}.fastq.gz"),
        s=os.path.join(dir["prinseq"],"{sample}_S{host}.fastq.gz"),
        s1=temp(os.path.join(dir["prinseq"],"{sample}_S1{host}.fastq.gz")),
        s2=temp(os.path.join(dir["prinseq"],"{sample}_S2{host}.fastq.gz")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"prinseq.yaml")
    params:
        params = config["qc"]["prinseq"]
    log:
        os.path.join(dir["log"], "prinseq.{sample}{host}.log")
    benchmark:
        os.path.join(dir["bench"],"prinseq.{sample}{host}.txt")
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
        r1=os.path.join(dir["temp"],"{sample}_single{host}.fastq.gz"),
    output:
        r1=os.path.join(dir["prinseq"],"{sample}_single{host}.fastq.gz"),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"prinseq.yaml")
    params:
        params = config["qc"]["prinseq"]
    log:
        os.path.join(dir["log"], "prinseq.{sample}{host}.log")
    benchmark:
        os.path.join(dir["bench"],"prinseq.{sample}{host}.txt")
    shell:
        """
        prinseq++ {params.params} \
            -out_gz \
            -threads {threads} \
            -out_good {output.r1} \
            -out_bad /dev/null \
            -fastq {input.r1} &> {log}
        """
