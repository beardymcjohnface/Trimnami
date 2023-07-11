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
dir.base = os.path.join(workflow.basedir, "..")
dir.env = os.path.join(workflow.basedir, "envs")
dir.scripts = os.path.join(workflow.basedir, "..", "scripts")
dir.db = os.path.join(workflow.basedir, "databases")

try:
    assert(ap.utils.to_dict(config.args)["output"]) is not None
    dir.out = config.args.output
except (KeyError, AssertionError):
    dir.out = "trimnami.out"

dir.temp = os.path.join(dir.out, "temp")
dir.log = os.path.join(dir.out, "logs")
dir.reports = os.path.join(dir.out, "reports")
dir.fastp = os.path.join(dir.out, "fastp")
dir.prinseq = os.path.join(dir.out, "prinseq")
dir.roundAB = os.path.join(dir.out, "roundAB")
dir.nanopore = os.path.join(dir.out, "nanopore")
dir.notrim = os.path.join(dir.out, "notrim")
dir.bench = os.path.join(dir.out, "benchmarks")


"""
Define file intermediates
"""
# Check if host removal
config.args.hostStr = ""
config.args.hostIndex = ""
config.args.subsampleStr = ""
if config.args.host is not None:
    # String to append to targets to signal host removal
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

"""
Define targets
"""
targets = ap.AttrMap()

# generate target base names
for sample_name in samples.names:
    if samples.reads[sample_name]["R2"] is not None:
        samples.reads[sample_name]["trimmed_targets"] = expand(
            sample_name + config.args.hostStr + ".paired" + "{R12}" + config.args.subsampleStr + ".fastq.gz",
            R12 = [".R1", ".R2", ".S"]
        )
        samples.reads[sample_name]["fastqc_targets"] = expand(
            sample_name + config.args.hostStr + config.args.subsampleStr + ".paired" + "{R12}" + config.args.subsampleStr + "_fastqc.zip",
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


# target lists
targets.fastp = []
targets.prinseq = []
targets.roundAB = []
targets.nanopore = []
targets.notrim = []

targets.fastqc.untrimmed = []
targets.fastqc.fastp = []
targets.fastqc.prinseq = []
targets.fastqc.roundAB = []
targets.fastqc.nanopore = []
targets.fastqc.notrim = []

targets.reports = [
    os.path.join(dir.out,"samples.tsv"),
]

# populate target lists
for sample_name in samples.names:
    targets.fastp += expand(os.path.join(dir.fastp, "{file}"), file=samples.reads[sample_name]["trimmed_targets"])
    targets.prinseq += expand(os.path.join(dir.prinseq, "{file}"), file=samples.reads[sample_name]["trimmed_targets"])
    targets.roundAB += expand(os.path.join(dir.roundAB, "{file}"), file=samples.reads[sample_name]["trimmed_targets"])
    targets.nanopore += expand(os.path.join(dir.nanopore, "{file}"), file=samples.reads[sample_name]["trimmed_targets"])
    targets.notrim += expand(os.path.join(dir.notrim, "{file}"), file=samples.reads[sample_name]["trimmed_targets"])

if config.args.fastqc:
    for sample_name in samples.names:
        targets.fastqc.untrimmed += expand(os.path.join(dir.reports,"untrimmed","{file}"), file=samples.reads[sample_name]["fastqc_untrimmed"])
        targets.fastqc.fastp += expand(os.path.join(dir.reports,"fastp","{file}"), file=samples.reads[sample_name]["fastqc_targets"])
        targets.fastqc.prinseq += expand(os.path.join(dir.reports,"prinseq","{file}"), file=samples.reads[sample_name]["fastqc_targets"])
        targets.fastqc.roundAB += expand(os.path.join(dir.reports,"roundAB","{file}"), file=samples.reads[sample_name]["fastqc_targets"])
        targets.fastqc.nanopore += expand(os.path.join(dir.reports,"nanopore","{file}"), file=samples.reads[sample_name]["fastqc_targets"])
        targets.fastqc.notrim += expand(os.path.join(dir.reports,"notrim","{file}"), file=samples.reads[sample_name]["fastqc_targets"])

    targets.fastp += [os.path.join(dir.reports, "fastp.fastqc.html"), os.path.join(dir.reports, "untrimmed.fastqc.html")]
    targets.prinseq += [os.path.join(dir.reports, "prinseq.fastqc.html"), os.path.join(dir.reports, "untrimmed.fastqc.html")]
    targets.roundAB += [os.path.join(dir.reports, "roundAB.fastqc.html"), os.path.join(dir.reports, "untrimmed.fastqc.html")]
    targets.nanopore += [os.path.join(dir.reports, "nanopore.fastqc.html"), os.path.join(dir.reports, "untrimmed.fastqc.html")]
    targets.notrim += [os.path.join(dir.reports, "notrim.fastqc.html"), os.path.join(dir.reports, "untrimmed.fastqc.html")]
