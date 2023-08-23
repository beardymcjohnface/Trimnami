@target_rule
rule roundAB:
    input:
        targets["output"]["roundAB"],


rule remove_5prime_primer:
    """Round A/B step 01: Remove 5' primer."""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2=lambda wildcards: samples["reads"][wildcards.sample]["R2"],
        primers=os.path.join(dir["db"],"primerB.fa")
    output:
        r1=temp(os.path.join(dir["temp"],"{sample}.R1.s1.fastq")),
        r2=temp(os.path.join(dir["temp"],"{sample}.R2.s1.fastq")),
        s=temp(os.path.join(dir["temp"],"{sample}.S.s1.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_5prime_primer.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_5prime_primer.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["rm_5p"],
        s= lambda wildcards: samples["reads"][wildcards.sample]["S"],
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            in2={input.r2} \
            ref={input.primers} \
            out={output.r1} \
            out2={output.r2} \
            threads={threads} \
            {params.params} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        if [[ -s {params.s} ]]
        then
            bbduk.sh \
                in={params.s} \
                ref={input.primers} \
                out={output.s} \
                threads={threads} \
                {params.params} \
                -Xmx{resources.mem_mb}m \
                2> {log}
        else
            touch {output.s}
        fi
        """


rule remove_3prime_contaminant:
    """Round A/B step 02: Remove 3' read through contaminant."""
    input:
        r1=os.path.join(dir["temp"],"{sample}.R1.s1.fastq"),
        r2=os.path.join(dir["temp"],"{sample}.R2.s1.fastq"),
        s=os.path.join(dir["temp"],"{sample}.S.s1.fastq"),
        primers=os.path.join(dir["db"],"rc_primerB_ad6.fa")
    output:
        r1=temp(os.path.join(dir["temp"],"{sample}.R1.s2.fastq")),
        r2=temp(os.path.join(dir["temp"],"{sample}.R2.s2.fastq")),
        s=temp(os.path.join(dir["temp"],"{sample}.S.s2.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_3prime_contaminant.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_3prime_contaminant.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = "00:00:01"
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["rm_3rt"]
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            in2={input.r2} \
            ref={input.primers} \
            out={output.r1} \
            out2={output.r2} \
            {params.params} \
            threads={threads} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        if [[ -s {input.s} ]]
        then
            bbduk.sh \
                in={input.s} \
                ref={input.primers} \
                out={output.s} \
                {params.params} \
                threads={threads} \
                -Xmx{resources.mem_mb}m \
                2> {log}
        else
            touch {output.s}
        fi
        """


rule remove_primer_free_adapter:
    """Round A/B step 03: Remove primer free adapter (both orientations)."""
    input:
        r1=os.path.join(dir["temp"],"{sample}.R1.s2.fastq"),
        r2=os.path.join(dir["temp"],"{sample}.R2.s2.fastq"),
        s=os.path.join(dir["temp"],"{sample}.S.s2.fastq"),
        primers=os.path.join(dir["db"],"nebnext_adapters.fa")
    output:
        r1=temp(os.path.join(dir["temp"],"{sample}.R1.s3.fastq")),
        r2=temp(os.path.join(dir["temp"],"{sample}.R2.s3.fastq")),
        s=temp(os.path.join(dir["temp"],"{sample}.S.s3.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_primer_free_adapter.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_primer_free_adapter.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = "00:00:01"
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["neb"]
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            in2={input.r2} \
            ref={input.primers} \
            out={output.r1} \
            out2={output.r2} \
            {params.params} \
            threads={threads} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        if [[ -s {input.s} ]]
        then
            bbduk.sh \
                in={input.s} \
                ref={input.primers} \
                out={output.s} \
                {params.params} \
                threads={threads} \
                -Xmx{resources.mem_mb}m \
                2> {log}
        else
            touch {output.s}
        fi
        """


rule remove_adapter_free_primer:
    """Round A/B step 04: Remove adapter free primer (both orientations)."""
    input:
        r1=os.path.join(dir["temp"],"{sample}.R1.s3.fastq"),
        r2=os.path.join(dir["temp"],"{sample}.R2.s3.fastq"),
        s=os.path.join(dir["temp"],"{sample}.S.s3.fastq"),
        primers=os.path.join(dir["db"],"rc_primerB_ad6.fa")
    output:
        r1=temp(os.path.join(dir["temp"],"{sample}.R1.s4.fastq")),
        r2=temp(os.path.join(dir["temp"],"{sample}.R2.s4.fastq")),
        s=temp(os.path.join(dir["temp"],"{sample}.S.s4.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_adapter_free_primer.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_adapter_free_primer.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = "00:00:01"
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["rm_afp"]
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            in2={input.r2} \
            ref={input.primers} \
            out={output.r1} \
            out2={output.r2} \
            {params.params} \
            threads={threads} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        if [[ -s {input.s} ]]
        then
            bbduk.sh \
                in={input.s} \
                ref={input.primers} \
                out={output.s} \
                {params.params} \
                threads={threads} \
                -Xmx{resources.mem_mb}m \
                2> {log}
        else
            touch {output.s}
        fi
        """


rule remove_vector_contamination:
    """Round A/B step 05: Vector contamination removal (PhiX + NCBI UniVecDB)"""
    input:
        r1=os.path.join(dir["temp"],"{sample}.R1.s4.fastq"),
        r2=os.path.join(dir["temp"],"{sample}.R2.s4.fastq"),
        s=os.path.join(dir["temp"],"{sample}.S.s4.fastq"),
        primers=os.path.join(dir["db"],"vector_contaminants.fa")
    output:
        r1=temp(os.path.join(dir["temp"],"{sample}.R1.s5.fastq")),
        r2=temp(os.path.join(dir["temp"],"{sample}.R2.s5.fastq")),
        s=temp(os.path.join(dir["temp"],"{sample}.S.s5.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_vector_contamination.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_vector_contamination.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = "00:00:01"
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["rm_vc"]
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            in2={input.r2} \
            ref={input.primers} \
            out={output.r1} \
            out2={output.r2} \
            {params.params} \
            threads={threads} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        if [[ -s {input.s} ]]
        then
            bbduk.sh \
                in={input.s} \
                ref={input.primers} \
                out={output.s} \
                {params.params} \
                threads={threads} \
                -Xmx{resources.mem_mb}m \
                2> {log}
        else
            touch {output.s}
        fi
        """


rule remove_low_quality:
    """Round A/B step 06: Remove remaining low-quality bases and short reads."""
    input:
        r1=os.path.join(dir["temp"],"{sample}.R1.s5.fastq"),
        r2=os.path.join(dir["temp"],"{sample}.R2.s5.fastq"),
        s=os.path.join(dir["temp"],"{sample}.S.s5.fastq"),
    output:
        r1=temp(os.path.join(dir["temp"],"{sample}.R1.s6.fastq")),
        r2=temp(os.path.join(dir["temp"],"{sample}.R2.s6.fastq")),
        s=temp(os.path.join(dir["temp"],"{sample}.S.s6.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_low_quality.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_low_quality.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = "00:00:01"
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["rm_lq"]
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            in2={input.r2} \
            out={output.r1} \
            out2={output.r2} \
            threads={threads} \
            {params.params} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        if [[ -s {input.s} ]]
        then
            bbduk.sh \
                in={input.s} \
                out={output.s} \
                threads={threads} \
                {params.params} \
                -Xmx{resources.mem_mb}m \
                2> {log}
        else
            touch {output.s}
        fi
        """


rule zip_roundAB:
    """Zip the final trimmed reads for Round A/B"""
    input:
        r1=os.path.join(dir["temp"],"{sample}.R1.s6.fastq"),
        r2=os.path.join(dir["temp"],"{sample}.R2.s6.fastq"),
        s=os.path.join(dir["temp"],"{sample}.S.s6.fastq"),
    output:
        r1=temp(os.path.join(dir["roundAB"],"{sample}_R1.fastq.gz")),
        r2=temp(os.path.join(dir["roundAB"],"{sample}_R2.fastq.gz")),
        s=temp(os.path.join(dir["roundAB"],"{sample}_RS.fastq.gz")),
    benchmark:
        os.path.join(dir["bench"],"zip_roundAB.{sample}.txt")
    log:
        os.path.join(dir["log"],"zip_roundAB.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = "00:00:01"
    threads:
        resources["med"]["cpu"]
    params:
        compression = config["qc"]["compression"]
    conda:
        os.path.join(dir["env"], "pigz.yaml")
    group:
        "roundAB"
    shell:
        """
        pigz -p {threads} -{params.compression} -c {input.r1} > {output.r1} 2> {log}
        pigz -p {threads} -{params.compression} -c {input.r2} > {output.r2} 2> {log}
        pigz -p {threads} -{params.compression} -c {input.s} > {output.s} 2> {log}
        """


rule roundAB_single_end:
    """Round A/B for single end: This should not occur but this rule is here for testing purposes."""
    input:
        r1=lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        r1=temp(os.path.join(dir["roundAB"],"{sample}_S.fastq.gz")),
        tmp=temp(os.path.join(dir["temp"],"{sample}_S.fastq")),
    benchmark:
        os.path.join(dir["bench"],"remove_low_quality.{sample}.txt")
    log:
        os.path.join(dir["log"],"remove_low_quality.{sample}.log")
    resources:
        mem_mb = resources["med"]["mem"],
        mem = str(resources["med"]["mem"]) + "MB",
        javaAlloc = int(0.9 * resources["med"]["mem"]),
        time = resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    params:
        params = config["qc"]["bbduk"]["rm_lq"],
        compression = config["qc"]["compression"]
    conda:
        os.path.join(dir["env"], "bbmap.yaml")
    group:
        "roundAB"
    shell:
        """
        bbduk.sh \
            in={input.r1} \
            out={output.tmp} \
            threads={threads} \
            {params.params} \
            -Xmx{resources.mem_mb}m \
            2> {log}
        gzip -c -{params.compression} {output.tmp} > {output.r1}
        """
