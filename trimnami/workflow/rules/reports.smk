rule sample_manifest:
    """Print the parsed sample manifest"""
    output:
        tsv = os.path.join(dir["out"],"samples.tsv")
    params:
        sample_dict = samples["reads"]
    localrule:
        True
    run:
        from metasnek import fastq_finder
        fastq_finder.write_samples_tsv(params.sample_dict,output.tsv)


rule buildEnv:
    output:
        os.path.join(dir["temp"], "{env}.done")
    conda:
        lambda wildcards: os.path.join(dir["env"], wildcards.env)
    shell:
        "touch {output}"
