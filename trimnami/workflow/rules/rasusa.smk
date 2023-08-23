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
        bases=lambda wildcards: config["args"]["subsample"] if config["args"]["subsample"] else ""
    benchmark:
        os.path.join(dir["bench"], "rasusa_single.{dir}.{file}.txt")
    log:
        os.path.join(dir["log"], "rasusa_single.{dir}.{file}.log")
    shell:
        ("if (( $(wc -c {input} | awk '{{print$1}}') > 200 )); then "
            "rasusa "
                "-i {input} "
                "-o {output} "
                "-O g "
                "--bases {params.bases} "
                "2> {log}; "
         "else "
            "touch {output}; "
         "fi ")
