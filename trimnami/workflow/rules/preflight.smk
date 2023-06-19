import attrmap as ap
import attrmap.utils as au
from metasnek import fastq_finder


# Parse samples
samples = ap.AttrMap()
samples.reads = fastq_finder.parse_samples_to_dictionary(config.args.reads)
samples.names = list(ap.utils.get_keys(samples.reads))
samples = au.convert_state(samples, read_only=True)
fastq_finder.write_samples_tsv(samples.reads, os.path.join(dir.out, "samples.tsv"))


# Directories
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
dir.result = os.path.join(dir.out, "results")
dir.bench = os.path.join(dir.out, "benchmarks")


# Targets
targets = ap.AttrMap()

