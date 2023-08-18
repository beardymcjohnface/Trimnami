rule fastq_to_fasta:
    """Conver the trimmed fastq file to a fasta file"""
    input:
        os.path.join("{dir}","{file}.fastq.gz")
    output:
        fastq = temp(os.path.join("{dir}","{file}.rm.fastq.gz")),
        fasta = os.path.join("{dir}","{file}.fasta.gz"),
    params:
        compression = "-" + config["qc"]["compression"]
    conda:
        os.path.join(dir["env"], "seqtk.yaml")
    shell:
        ("mv {input} {output.fastq}; "
        "seqtk seq {output.fastq} -A "
            "| gzip {params.compression} "
            "> {output.fasta}")
