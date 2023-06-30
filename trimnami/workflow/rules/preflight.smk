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


"""
Define targets
"""
targets = ap.AttrMap()

# generate target base names
for sample_name in samples.names:
    if samples.reads[sample_name]["R2"] is not None:
        samples.reads[sample_name]["targetNames"] = expand(
            sample_name + config.args.hostStr + ".paired" + "{R12}.fastq.gz",
            R12 = [".R1", ".R2", ".S"]
        )
    else:
        samples.reads[sample_name]["targetNames"] = [sample_name + config.args.hostStr + ".single" + ".fastq.gz"]


# lock samples from further changes
samples = au.convert_state(samples, read_only=True)


# target lists
targets.fastp = []
targets.prinseq = []
targets.roundAB = []
targets.nanopore = []
targets.notrim = []
targets.reports = [
    os.path.join(dir.out,"samples.tsv"),
]

# populate target lists
for sample_name in samples.names:
    targets.fastp.append(expand(os.path.join(dir.fastp, "{file}"), file=samples.reads[sample_name]["targetNames"]))
    targets.prinseq.append(expand(os.path.join(dir.prinseq, "{file}"), file=samples.reads[sample_name]["targetNames"]))
    targets.roundAB.append(expand(os.path.join(dir.roundAB, "{file}"), file=samples.reads[sample_name]["targetNames"]))
    targets.nanopore.append(expand(os.path.join(dir.nanopore, "{file}"), file=samples.reads[sample_name]["targetNames"]))
    targets.notrim.append(expand(os.path.join(dir.notrim, "{file}"), file=samples.reads[sample_name]["targetNames"]))
