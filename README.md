![](trimnami.png)

[![](https://img.shields.io/static/v1?label=CLI&message=Snaketool&color=blueviolet)](https://github.com/beardymcjohnface/Snaketool)
[![](https://img.shields.io/static/v1?label=Licence&message=MIT&color=black)](https://opensource.org/license/mit/)
![](https://img.shields.io/static/v1?label=Install%20with&message=PIP&color=success)

---

Trim lots of metagenomics samples all at once.

## Motivation

We keep writing pipelines that start with read trimming.
Rather than copy-pasting code each time,
this standalone Snaketool handles our trimming needs.
The tool will collect sample names and files from a directory or TSV file,
optionally remove host reads, and trim with your favourite read trimmer.
Read trimming methods supported so far:

- Fastp
- Prinseq++
- BBtools for Round A/B viral metagenomics
- Filtlong + Rasusa for longreads

## Install

Trimnami is still in development but can be easily installed with pip:

```shell
git clone https://github.com/beardymcjohnface/Trimnami.git
cd Trimnami/
pip install -e .
```

## Test

Trimnami comes with inbuilt tests which you can run to check everything works fine.

```shell
# test fastp only (default method)
trimnami test

# test all SR methods
trimnami test fastp prinseq roundAB

# test all SR methods with host removal
trimnami testhost fastp prinseq roundAB

# test nanopore method (with host removal)
trimnami testnp
```

## Usage

Trim reads with Fastp or Prinseq++

```shell
# Fastp (default)
trimnami run --reads reads/

# Prinseq++
trimnami run --reads reads/ prinseq

# Why not both!
trimnami run --reads reads/ fastp prinseq
```

Include host removal

```shell
trimnami run --reads reads/ --host host_genome.fasta
```

Longreads with host removal.
Specify 'nanopore' for targets and use the appropriate minimap preset.

```shell
trimnami run \
    --reads reads/ \
    --host host_genome.fasta \
    --minimap map-ont \
    nanopore
```

## Parsing sample names and reads

Samples are parsed using MetaSnek fastq_finder:
[Parsing samples with MetaSnek](https://gist.github.com/beardymcjohnface/bb161ba04ae1042299f48a4849e917c8)

## Outputs

Trimmed reads will be saved in various subfolders in the output directory.
e.g. if trimming with Fastp or Prinseq++, 
trimmed reads will be in `trimnami.out/fastp/` or `trimnami.out/prinseq/`.
Paired reads will yield three files: 
The R1 and R2 paired reads, and any singletons from trimming or host removal.
Example output:

```text
# paired reads
sampleName.paired.R1.fastq.gz
sampleName.paired.R2.fastq.gz
sampleName.paired.S.fastq.gz

# unpaired
sampleName.single.fastq.gz

# paired with host removal
sampleName.host_rm.paired.R1.fastq.gz
sampleName.host_rm.paired.R2.fastq.gz
sampleName.host_rm.paired.S.fastq.gz
```
