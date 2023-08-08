![](trimnami.png)

[![](https://img.shields.io/static/v1?label=CLI&message=Snaketool&color=blueviolet)](https://github.com/beardymcjohnface/Snaketool)
[![](https://img.shields.io/static/v1?label=Licence&message=MIT&color=black)](https://opensource.org/license/mit/)
[![](https://img.shields.io/static/v1?label=Install%20with&message=PIP&color=success)](https://pypi.org/project/trimnami/)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/beardymcjohnface/Trimnami/main)
[![Unit tests](https://github.com/beardymcjohnface/Trimnami/actions/workflows/python-app.yml/badge.svg)](https://github.com/beardymcjohnface/Trimnami/actions/workflows/python-app.yml)
[![codecov](https://codecov.io/gh/beardymcjohnface/Trimnami/branch/main/graph/badge.svg?token=E0w8zHLLDq)](https://codecov.io/gh/beardymcjohnface/Trimnami)


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
 
__Easy install__

```shell
pip install trimnami
```

__Developer install__
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

## Parsing samples with `--reads`

You can pass either a directory of reads or a TSV file to `--reads`.
 - __Directory:__ Trimnami will infer sample names and \_R1/\_R2 pairs from the filenames.
 - __TSV file:__ Trimnami expects 2 or 3 columns, with column 1 being the sample name and columns 2 and 3 the reads files.

__[More information and examples here](https://gist.github.com/beardymcjohnface/bb161ba04ae1042299f48a4849e917c8#file-readme-md)__

## Configure trimming parameters

You can customise the trimming parameters via the config file.
Copy the default config file.

```shell
trimnami config
```

Then edit the config file `trimnami.out/trimnami.config.yaml` in your favourite text editor.
Run trimnami like normal, or point to your custom config file if you've moved it.

```shell
trimnami run ... --configfile /my/awesome/config.yaml
```

## Outputs

Trimmed reads will be saved in various subfolders in the output directory.
e.g. if trimming with Fastp or Prinseq++, 
trimmed reads will be in `trimnami.out/fastp/` or `trimnami.out/prinseq/`.
Paired reads will yield three files: 
The R1 and R2 paired reads, and any singletons from trimming or host removal.
Subsampling will produce extra files of subsampled trimmed reads.
Multiqc-fastqc reports for any runs will be available in `trimnami.out/reports/`

### Example outputs
<details>
    <summary>Click to expand</summary>

prinseq

```text
trimnami.out/
└── prinseq
    ├── A13-04-182-06_TAGCTT.paired.R1.fastq.gz
    ├── A13-04-182-06_TAGCTT.paired.R2.fastq.gz
    ├── A13-04-182-06_TAGCTT.paired.S.fastq.gz
    ├── A13-12-250-06_GGCTAC.paired.R1.fastq.gz
    ├── A13-12-250-06_GGCTAC.paired.R2.fastq.gz
    ├── A13-12-250-06_GGCTAC.paired.S.fastq.gz
    └── A13-135-177-06_AGTTCC.single.fastq.gz
```

prinseq with fastqc reports

```text
trimnami.out/
├── prinseq
│   ├── A13-04-182-06_TAGCTT.paired.R1.fastq.gz
│   ├── A13-04-182-06_TAGCTT.paired.R2.fastq.gz
│   ├── A13-04-182-06_TAGCTT.paired.S.fastq.gz
│   ├── A13-12-250-06_GGCTAC.paired.R1.fastq.gz
│   ├── A13-12-250-06_GGCTAC.paired.R2.fastq.gz
│   ├── A13-12-250-06_GGCTAC.paired.S.fastq.gz
│   └── A13-135-177-06_AGTTCC.single.fastq.gz
└── reports
    ├── prinseq.fastqc.html
    └── untrimmed.fastqc.html

```

prinseq with host removal

```text
trimnami.out/
└── prinseq
    ├── A13-04-182-06_TAGCTT.host_rm.paired.R1.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.R2.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.S.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.R1.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.R2.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.S.fastq.gz
    └── A13-135-177-06_AGTTCC.host_rm.single.fastq.gz
```

prinseq with host removal and subsampling

```text
trimnami.out/
└── prinseq
    ├── A13-04-182-06_TAGCTT.host_rm.paired.R1.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.R1.subsampled.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.R2.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.R2.subsampled.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.S.fastq.gz
    ├── A13-04-182-06_TAGCTT.host_rm.paired.S.subsampled.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.R1.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.R1.subsampled.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.R2.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.R2.subsampled.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.S.fastq.gz
    ├── A13-12-250-06_GGCTAC.host_rm.paired.S.subsampled.fastq.gz
    ├── A13-135-177-06_AGTTCC.host_rm.single.fastq.gz
    └── A13-135-177-06_AGTTCC.host_rm.single.subsampled.fastq.gz
```
</details>

