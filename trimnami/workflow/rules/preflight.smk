import attrmap as ap
import attrmap.utils as au
from metasnek import fastq_finder


"""
Parse the samples with metasnek
"""
samples = ap.AttrMap()
samples.reads = fastq_finder.parse_samples_to_dictionary(config.args.reads)
samples.names = list(ap.utils.get_keys(samples.reads))


"""
Define directories
"""
dir = ap.AttrMap()

# system directories
dir.base = os.path.join(workflow.basedir, "..")
dir.env = os.path.join(workflow.basedir, "envs")
dir.scripts = os.path.join(workflow.basedir, "..", "scripts")
dir.db = os.path.join(workflow.basedir, "databases")

# output directories
try:
    assert(ap.utils.to_dict(config.args)["output"]) is not None
    dir.out = config.args.output
except (KeyError, AssertionError):
    dir.out = "trimnami.out"

# misc output directories
dir.temp = os.path.join(dir.out, "temp")
dir.log = os.path.join(dir.out, "logs")
dir.reports = os.path.join(dir.out, "reports")
dir.bench = os.path.join(dir.out, "benchmarks")

# trimmer output directories
for trimmer in config.trimmers:
    dir[trimmer] = os.path.join(dir.out, trimmer)


"""
Define target filename suffixes
"""
# Check if host removal and subsampling
config.args.hostStr = ""
config.args.hostIndex = ""
config.args.subsampleStr = ""

if config.args.host is not None:
    config.args.hostStr = ".host_rm"
    # Minimap2 index file for mapping
    config.args.hostIndex = os.path.join(
        dir.temp,
        os.path.splitext(
            os.path.basename(config.args.host)
        )[0] + ".idx"
    )

if config.args.subsample is not None:
    config.args.subsampleStr = ".subsampled"

# generate target base names
for sample_name in samples.names:
    if samples.reads[sample_name]["R2"] is not None:
        samples.reads[sample_name]["trimmed_targets"] = expand(
            sample_name + config.args.hostStr + ".paired" + "{R12}" + config.args.subsampleStr + ".fastq.gz",
            R12 = [".R1", ".R2", ".S"]
        )
        samples.reads[sample_name]["fastqc_targets"] = expand(
            sample_name + config.args.hostStr + ".paired" + "{R12}" + config.args.subsampleStr + "_fastqc.zip",
            R12 = [".R1", ".R2", ".S"]
        )
        samples.reads[sample_name]["fastqc_untrimmed"] = expand(
            sample_name + ".paired" + "{R12}_fastqc.zip",
            R12=[".R1", ".R2"]
        )
    else:
        samples.reads[sample_name]["trimmed_targets"] = [sample_name + config.args.hostStr + ".single" + config.args.subsampleStr + ".fastq.gz"]
        samples.reads[sample_name]["fastqc_targets"] = [sample_name + config.args.hostStr + ".single" + config.args.subsampleStr + "_fastqc.zip"]
        samples.reads[sample_name]["fastqc_untrimmed"] = [sample_name + ".untrimmed.single_fastqc.zip"]


# lock samples from further changes
samples = au.convert_state(samples, read_only=True)


"""
Define the actual targets
"""
# target lists
targets = ap.AttrMap()

targets.fastqc.untrimmed = []
for trimmer in config.trimmers:
    targets[trimmer] = []
    targets.fastqc[trimmer] = []

    # populate triming targets
    for sample_name in samples.names:
        targets[trimmer] += expand(os.path.join(dir[trimmer], "{file}"), file=samples.reads[sample_name]["trimmed_targets"])

    # populate fastqc targets
    if config.args.fastqc:
        targets[trimmer] += [
            os.path.join(dir.reports, trimmer + ".fastqc.html"),
            os.path.join(dir.reports, "untrimmed.fastqc.html")
        ]
        for sample_name in samples.names:
            targets.fastqc.untrimmed += expand(
                os.path.join(dir.reports, "untrimmed","{file}"),
                file=samples.reads[sample_name]["fastqc_untrimmed"]
            )
            targets.fastqc[trimmer] += expand(
                os.path.join(dir.reports, trimmer, "{file}"),
                file=samples.reads[sample_name]["fastqc_targets"]
            )


"""
Other targets
"""
targets.reports = [
    os.path.join(dir.out,"samples.tsv"),
]