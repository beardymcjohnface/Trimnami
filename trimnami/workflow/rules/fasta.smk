rule fastq_to_fasta:
    """Convert the trimmed fastq file to a fasta file"""
    input:
        os.path.join(dir["temp"], "{dir}","{file}.fastq.gz")
    output:
        temp(os.path.join(dir["temp"], "{dir}","{file}.fasta.gz")),
    params:
        compression = "-" + str(config["qc"]["compression"])
    conda:
        os.path.join(dir["env"], "seqtk.yaml")
    shell:
        ("seqtk seq {input} -A "
            "| gzip {params.compression} "
            "> {output}")
