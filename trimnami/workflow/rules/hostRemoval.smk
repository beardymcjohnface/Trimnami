rule index_host_genome:
    """Pre-index the host genome for mapping with minimap2"""
    input:
        lambda wildcards: config["args"]["host"] if config["args"]["host"] else ""
    output:
        config["args"]["hostIndex"]
    params:
        params = config["qc"]["minimapIndex"]
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"minimap2.yaml")
    benchmark:
        os.path.join(dir["bench"],"index_host_genome.txt")
    log:
        os.path.join(dir["log"],"index_host_genome.log")
    shell:
        """minimap2 -t {threads} {params} -d {output} {input} &> {log}"""


rule host_removal_mapping_paired:
    """Map reads to host and return unmapped reads"""
    input:
        r1=os.path.join("{dir}","{sample}_R1.fastq.gz"),
        r2=os.path.join("{dir}","{sample}_R2.fastq.gz"),
        s=os.path.join("{dir}","{sample}_S.fastq.gz"),
        host=lambda wildcards: config["args"]["hostIndex"] if config["args"]["host"] else ""
    output:
        r1=os.path.join("{dir}","{sample}_R1.host_rm.fastq.gz"),
        r2=os.path.join("{dir}","{sample}_R2.host_rm.fastq.gz"),
        rs=os.path.join("{dir}","{sample}_S.host_rm.fastq.gz"),
        t1=temp(os.path.join("{dir}","rm.{sample}_R1.fastq.gz")),
        t2=temp(os.path.join("{dir}","rm.{sample}_R2.fastq.gz")),
        ts=temp(os.path.join("{dir}","rm.{sample}_S.fastq.gz")),
        s=temp(os.path.join("{dir}","rm.{sample}_s.host_rm.fastq.gz")),
        o=temp(os.path.join("{dir}","rm.{sample}_o.host_rm.fastq.gz")),
        O=temp(os.path.join("{dir}","rm.{sample}_O.host_rm.fastq.gz")),
    params:
        compression=config["qc"]["compression"],
        minimap_mode=config["args"]["minimap"],
        flagFilt=config["qc"]["hostRemoveFlagstat"]
    benchmark:
        os.path.join(dir["bench"],"host_removal_mapping.{dir}.{sample}.txt")
    log:
        mm=os.path.join(dir["log"],"host_removal_mapping.{dir}.{sample}.minimap.log"),
        sv=os.path.join(dir["log"],"host_removal_mapping.{dir}.{sample}.samtoolsView.log"),
        fq=os.path.join(dir["log"],"host_removal_mapping.{dir}.{sample}.samtoolsFastq.log"),
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"minimap2.yaml")
    shell:
        """
        mv {input.r1} {output.t1}
        mv {input.r2} {output.t2}
        minimap2 -ax {params.minimap_mode} -t {threads} --secondary=no {input.host} {output.t1} {output.t2} 2> {log.mm} \
            | samtools view -h {params.flagFilt} 2> {log.sv} \
            | samtools fastq -N -O -c {params.compression} -1 {output.r1} -2 {output.r2} -0 {output.O} -s {output.rs} 2> {log.fq}
        cat {output.O} >> {output.rs}
        if [[ -s {input.s} ]]
        then
            mv {input.s} {output.ts}
            minimap2 -ax {params.minimap_mode} -t {threads} --secondary=no {input.host} {output.ts} 2> {log.mm} \
                | samtools view -h {params.flagFilt} 2> {log.sv} \
                | samtools fastq -n -O -c {params.compression} -o {output.o} -0 {output.O} -s {output.s} 2> {log.fq}
            cat {output.o} {output.O} {output.s} >> {output.rs}
        fi
        """


rule host_removal_mapping_single:
    """Map reads to host and return unmapped reads"""
    input:
        r1=os.path.join("{dir}","{sample}_single.fastq.gz"),
        host=lambda wildcards: config["args"]["hostIndex"] if config["args"]["host"] else ""
    output:
        r1=os.path.join("{dir}","{sample}_single.host_rm.fastq.gz"),
        t1=temp(os.path.join("{dir}","rm.{sample}_single.fastq.gz")),
        s=temp(os.path.join("{dir}","{sample}_single.host_rm.S.fastq.gz")),
        o=temp(os.path.join("{dir}","{sample}_single.host_rm.O.fastq.gz")),
    params:
        compression=config["qc"]["compression"],
        minimap_mode=config["args"]["minimap"],
        flagFilt=config["qc"]["hostRemoveFlagstat"]
    benchmark:
        os.path.join(dir["bench"],"host_removal_mapping.{dir}.{sample}.txt")
    log:
        mm=os.path.join(dir["log"],"host_removal_mapping.{dir}.{sample}.minimap.log"),
        sv=os.path.join(dir["log"],"host_removal_mapping.{dir}.{sample}.samtoolsView.log"),
        fq=os.path.join(dir["log"],"host_removal_mapping.{dir}.{sample}.samtoolsFastq.log")
    resources:
        mem_mb=resources["med"]["mem"],
        mem=str(resources["med"]["mem"]) + "MB",
        time=resources["med"]["time"]
    threads:
        resources["med"]["cpu"]
    conda:
        os.path.join(dir["env"],"minimap2.yaml")
    shell:
        """
        mv {input.r1} {output.t1}
        minimap2 -ax {params.minimap_mode} -t {threads} --secondary=no {input.host} {output.t1} 2> {log.mm} \
            | samtools view -h {params.flagFilt} 2> {log.sv} \
            | samtools fastq -n -O -c {params.compression} -o {output.r1} -0 {output.o} -s {output.s} 2> {log.fq}
        cat {output.o} {output.s} >> {output.r1}
        """


rule skip_host_rm_paired:
    """Skip host removal of paired reads"""
    input:
        r1 = lambda wildcards: samples["reads"][wildcards.sample]["R1"],
        r2 = lambda wildcards: samples["reads"][wildcards.sample]["R2"],
    output:
        r1 = temp(os.path.join(dir["temp"],"{sample}_R1.fastq.gz")),
        r2 = temp(os.path.join(dir["temp"],"{sample}_R2.fastq.gz")),
        s = temp(os.path.join(dir["temp"],"{sample}_S.fastq.gz")),
    params:
        is_paired = True
    localrule:
        True
    log:
        stderr = os.path.join(dir["log"], "skip_host_rm_pair.{sample}.err"),
        stdout = os.path.join(dir["log"], "skip_host_rm_pair.{sample}.out")
    script:
        os.path.join(dir["scripts"], "skipHostRm.py")


rule skip_host_rm_single:
    """Skip host removal of paired reads"""
    input:
        r1 = lambda wildcards: samples["reads"][wildcards.sample]["R1"],
    output:
        r1 = temp(os.path.join(dir["temp"],"{sample}_single.fastq.gz")),
    params:
        is_paired = False
    localrule:
        True
    script:
        os.path.join(dir["scripts"], "skipHostRm.py")
