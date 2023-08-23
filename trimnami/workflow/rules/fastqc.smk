rule fastqc_paired_untrimmed:
    input:
        r1 = lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2 = lambda wildcards: samples["reads"][wildcards.sample]["R2"],
    output:
        z1 = temp(os.path.join(dir["reports"],"untrimmed","{sample}_R1_fastqc.zip")),
        z2 = temp(os.path.join(dir["reports"],"untrimmed","{sample}_R2_fastqc.zip")),
        t=touch(temp(os.path.join(dir["temp"],"{sample}.untrimmed.fastqc")))
    params:
        dir = dir["temp"],
        r1 = lambda wildcards: os.path.join(dir["temp"],re.sub(r"\.(fasta|fastq)(\.gz)?$","",os.path.basename(
            samples["reads"][wildcards.sample]["R1"])) + "_fastqc.html"),
        r2 = lambda wildcards: os.path.join(dir["temp"],re.sub(r"\.(fasta|fastq)(\.gz)?$","",os.path.basename(
            samples["reads"][wildcards.sample]["R2"])) + "_fastqc.html"),
        z1 = lambda wildcards: os.path.join(dir["temp"],re.sub(r"\.(fasta|fastq)(\.gz)?$","",os.path.basename(
            samples["reads"][wildcards.sample]["R1"])) + "_fastqc.zip"),
        z2 = lambda wildcards: os.path.join(dir["temp"],re.sub(r"\.(fasta|fastq)(\.gz)?$","",os.path.basename(
            samples["reads"][wildcards.sample]["R2"])) + "_fastqc.zip"),
    conda:
        os.path.join(dir["env"], "fastqc.yaml")
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    log:
        os.path.join(dir["log"], "fastqc_paired_untrimmed.{sample}.log")
    benchmark:
        os.path.join(dir["bench"],"fastqc_paired_untrimmed.{sample}.txt")
    shell:
        ("fastqc {input} "
            "-t {threads} "
            "--outdir {params.dir} "
            "&> {log}; "
        "mv {params.z1} {output.z1}; "
        "mv {params.z2} {output.z2}; "
        "rm {params.r1} {params.r2}; ")


rule fastqc_unpaired_untrimmed:
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        z1=temp(os.path.join(dir["reports"],"untrimmed","{sample}.untrimmed_single_fastqc.zip")),
        t=touch(temp(os.path.join(dir["temp"],"{sample}.untrimmed.fastqc")))
    params:
        dir=dir["temp"],
        r1=lambda wildcards: os.path.join(dir["temp"],re.sub(r"\.(fasta|fastq)(\.gz)?$","",os.path.basename(
            samples["reads"][wildcards.sample]["R1"])) + "_fastqc.html"),
        z1=lambda wildcards: os.path.join(dir["temp"],re.sub(r"\.(fasta|fastq)(\.gz)?$","",os.path.basename(
            samples["reads"][wildcards.sample]["R1"])) + "_fastqc.zip"),
    conda:
        os.path.join(dir["env"],"fastqc.yaml")
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    log:
        os.path.join(dir["log"],"fastqc_unpaired_untrimmed.{sample}.log")
    benchmark:
        os.path.join(dir["bench"],"fastqc_unpaired_untrimmed.{sample}.txt")
    shell:
        ("fastqc {input} "
            "-t {threads} "
            "--outdir {params.dir} "
            "&> {log}; "
        "mv {params.z1} {output.z1}; "
        "rm {params.r1}; ")


rule fastqc_trimmed:
    input:
        os.path.join(dir["temp"],"{trimmer}","{file}.fastq.gz"),
    output:
        r=temp(os.path.join(dir["temp"],"{trimmer}","{file}_fastqc.html")),
        z=temp(os.path.join(dir["reports"],"{trimmer}","{file}_fastqc.zip")),
    params:
        dir=os.path.join(dir["temp"],"{trimmer}"),
        z=os.path.join(dir["temp"],"{trimmer}","{file}_fastqc.zip"),
    conda:
        os.path.join(dir["env"],"fastqc.yaml")
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    log:
        os.path.join(dir["log"],"fastqc_trimmed.{trimmer}{file}.log")
    benchmark:
        os.path.join(dir["bench"],"fastqc_trimmed.{trimmer}{file}.txt")
    shell:
        ("if [[ -s {input} ]]; then "
            "fastqc {input} "
                "-t {threads} "
                "--outdir {params.dir} "
                "&> {log}; "
            "mv {params.z} {output.z}; "
        "else "
            "touch {output}; "
        "fi; ")


rule multiqc_fastqc:
    input:
        lambda wildcards: targets["fastqc"][wildcards.trimUntrim]
    output:
        os.path.join(dir["reports"], "{trimUntrim}.fastqc.html")
    params:
        dir=os.path.join(dir["reports"], "{trimUntrim}")
    conda:
        os.path.join(dir["env"],"multiqc.yaml")
    log:
        os.path.join(dir["log"],"multiqc_fastqc.{trimUntrim}.log")
    benchmark:
        os.path.join(dir["bench"],"multiqc_fastqc.{trimUntrim}.txt")
    shell:
        "multiqc {params.dir} -n {output} --no-data-dir 2> {log}"
