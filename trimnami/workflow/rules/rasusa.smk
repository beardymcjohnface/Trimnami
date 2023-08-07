rule rasusa_single:
    input:
        i=os.path.join(dir["out"], "{dir}", "{sample}_single{host}.fastq.gz")
    output:
        o=os.path.join(dir["out"], "{dir}", "{sample}_single{host}.subsampled.fastq.gz"),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"], "rasusa.yaml")
    params:
        bases=lambda wildcards: config["args"]["subsample"] if config["args"]["subsample"] else ""
    benchmark:
        os.path.join(dir["bench"], "rasusa_single.{dir}.{sample}{host}.txt")
    log:
        os.path.join(dir["log"], "rasusa_single.{dir}.{sample}{host}.log")
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
        r1=os.path.join(dir["out"], "{dir}", "{sample}_R1.fastq.gz"),
        r2=os.path.join(dir["out"], "{dir}", "{sample}_R2.fastq.gz"),
        rs=os.path.join(dir["out"], "{dir}", "{sample}_S.fastq.gz"),
    output:
        r1=os.path.join(dir["out"], "{dir}", "{sample}_R1{host}.subsampled.fastq.gz"),
        r2=os.path.join(dir["out"], "{dir}", "{sample}_R2{host}.subsampled.fastq.gz"),
        rs=os.path.join(dir["out"], "{dir}", "{sample}_S{host}.subsampled.fastq.gz"),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"], "rasusa.yaml")
    params:
        bases=lambda wildcards: config["args"]["subsample"] if config["args"]["subsample"] else ""
    benchmark:
        os.path.join(dir["bench"], "rasusa_paired.{dir}.{sample}{host}.txt")
    log:
        os.path.join(dir["log"], "rasusa_paired.{dir}.{sample}{host}.log")
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
        
        if (( $(wc -c {input.rs} | awk '{{print$1}}') > 100 ))
        then
            rasusa \
                -i {input.rs} \
                -o {output.rs} \
                -O g \
                --bases {params.bases} \
                2> {log}
        else
            touch {output.rs}
        fi
        """