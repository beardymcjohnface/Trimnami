rule rasusa:
    input:
        os.path.join(dir["temp"], "{dir}", "{file}.fastq.gz")
    output:
        temp(os.path.join(dir["temp"], "{dir}", "{file}.subsampled.fastq.gz")),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"], "rasusa.yaml")
    params:
        config["qc"]["subsample"]
    benchmark:
        os.path.join(dir["bench"], "rasusa_single.{dir}.{file}.txt")
    log:
        os.path.join(dir["log"], "rasusa_single.{dir}.{file}.log")
    shell:
        ("if (( $(wc -c {input} | awk '{{print$1}}') > 200 ))\n then "
            "rasusa reads "
                "-o {output} "
                "-O g "
                "{params} "
                "{input} "
                "2> {log}\n "
         "else "
            "touch {output}\n "
         "fi\n\n ")
