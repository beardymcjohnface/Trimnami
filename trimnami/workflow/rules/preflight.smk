import attrmap as ap
import attrmap.utils as au
from metasnek import fastq_finder


"""
Parse the samples with metasnek
"""
samples = ap.AttrMap()
samples.reads = fastq_finder.parse_samples_to_dictionary(config.args.reads)
samples.names = list(ap.utils.get_keys(samples.reads))
samples = au.convert_state(samples, read_only=True)


"""
Define directories
"""
dir = ap.AttrMap()
dir.base = os.path.join(workflow.basedir, "..")
dir.env = os.path.join(workflow.basedir, "envs")
dir.scripts = os.path.join(dir.base, "scripts")

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
dir.bench = os.path.join(dir.out, "benchmarks")


"""
Define targets
"""
targets = ap.AttrMap()

# remove host?
config.args.hostStr = ""
if config.args.host:
    config.args.hostStr = ".host_removed"

# generate target base names
for sample_name in samples.names:
    if samples.reads[sample_name]["R2"]:
        samples.reads[sample_name]["targetNames"] = expand(
            sample_name + ".paired" + config.args.hostStr + "{R12}.fastq.gz",
            R12 = ["R1", "R2"]
        )
    else:
        samples.reads[sample_name]["targetNames"] = [sample_name + ".single" + config.args.hostStr + ".fastq.gz"]

# target lists
targets.fastp = []
targets.prinseq = []
targets.roundAB = []

# populate target lists
for sample_name in samples.names:
    targets.fastp.append(os.path.join(dir.fastp, "{file}"), file=samples.reads[sample_name]["targetNames"])
    targets.prinseq.append(os.path.join(dir.prinseq, "{file}"), file=samples.reads[sample_name]["targetNames"])
    targets.roundAB.append(os.path.join(dir.roundAB, "{file}"), file=samples.reads[sample_name]["targetNames"])
