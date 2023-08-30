from metasnek import fastq_finder


"""
Parse the samples with metasnek
"""
samples = dict()
samples["reads"] = fastq_finder.parse_samples_to_dictionary(config["args"]["reads"])
samples["names"] = list(samples["reads"].keys())


"""
Define directories
"""
dir = dict()

# system directories
dir["base"] = os.path.join(workflow.basedir, "..")
dir["env"] = os.path.join(workflow.basedir, "envs")
dir["scripts"] = os.path.join(workflow.basedir, "..", "scripts")
dir["db"] = os.path.join(workflow.basedir, "databases")

# output directories
try:
    assert(config["args"]["output"]) is not None
    dir["out"] = config["args"]["output"]
except (KeyError, AssertionError):
    dir["out"] = "trimnami.out"

# misc output directories
dir["temp"] = os.path.join(dir["out"], "temp")
dir["results"] = os.path.join(dir["out"], "results")
dir["log"] = os.path.join(dir["out"], "logs")
dir["reports"] = os.path.join(dir["out"], "reports")
dir["bench"] = os.path.join(dir["out"], "benchmarks")

# trimmer temp output directories
for trimmer in config["trimmers"]:
    dir[trimmer] = os.path.join(dir["temp"], trimmer)

# trimmer final output directories
dir["output"] = dict()
for trimmer in config["trimmers"]:
    dir["output"][trimmer] = os.path.join(dir["results"], trimmer)


"""
Define target filename suffixes
"""
# Check if host removal and subsampling
config["args"]["hostStr"] = ""
config["args"]["hostIndex"] = ""
config["args"]["subsampleStr"] = ""
config["args"]["outFormat"] = ".fastq"

if config["args"]["host"] is not None:
    config["args"]["hostStr"] = ".host_rm"
    config["args"]["hostIndex"] = os.path.join(
        dir["temp"],
        os.path.splitext(
            os.path.basename(config["args"]["host"])
        )[0] + ".idx"
    )

if config["args"]["subsample"]:
    config["args"]["subsampleStr"] = ".subsampled"

if config["args"]["fasta"]:
    config["args"]["outFormat"] = ".fasta"


# generate target base names
for sample_name in samples["names"]:
    if samples["reads"][sample_name]["R2"] is not None:
        samples["reads"][sample_name]["trimmed_targets"] = expand(
            sample_name + "{R12}" + config["args"]["hostStr"] + config["args"]["subsampleStr"] + config["args"]["outFormat"] + ".gz",
            R12 = ["_R1", "_R2", "_RS"]
        )
        samples["reads"][sample_name]["fastqc_targets"] = expand(
            sample_name + "{R12}" + config["args"]["hostStr"] + config["args"]["subsampleStr"] + "_fastqc.zip",
            R12 = ["_R1", "_R2", "_RS"]
        )
        samples["reads"][sample_name]["fastqc_untrimmed"] = expand(
            sample_name + "{R12}_fastqc.zip",
            R12=["_R1", "_R2"]
        )
    else:
        samples["reads"][sample_name]["trimmed_targets"] = [
            sample_name + "_S" + config["args"]["hostStr"] + config["args"]["subsampleStr"] + config["args"]["outFormat"] + ".gz",
        ]
        samples["reads"][sample_name]["fastqc_targets"] = [
            sample_name + "_S" + config["args"]["hostStr"] + config["args"]["subsampleStr"] + "_fastqc.zip"
        ]
        samples["reads"][sample_name]["fastqc_untrimmed"] = [
            sample_name + ".untrimmed_single_fastqc.zip"
        ]


"""
Define the actual targets
"""
targets = dict()
targets["fastqc"] = dict()
targets["fastqc"]["untrimmed"] = []
targets["output"] = dict()

for trimmer in config["trimmers"]:
    targets[trimmer] = []
    targets["output"][trimmer] = []
    targets["fastqc"][trimmer] = []

    # populate the temp triming targets
    for sample_name in samples["names"]:
        targets[trimmer] += expand(os.path.join(dir[trimmer], "{file}"), file=samples["reads"][sample_name]["trimmed_targets"])

    # populate the final trimming output targets
    for sample_name in samples["names"]:
        targets["output"][trimmer] += expand(
            os.path.join(dir["output"][trimmer], "{file}"),
            file=samples["reads"][sample_name]["trimmed_targets"])
        targets["output"][trimmer] += [os.path.join(dir["out"],"samples.tsv")]

    # populate fastqc targets
    if config["args"]["fastqc"]:
        targets["output"][trimmer] += [
            os.path.join(dir["reports"], trimmer + ".fastqc.html"),
            os.path.join(dir["reports"], "untrimmed.fastqc.html")
        ]
        for sample_name in samples["names"]:
            targets["fastqc"]["untrimmed"] += expand(
                os.path.join(dir["reports"], "untrimmed", "{file}"),
                file=samples["reads"][sample_name]["fastqc_untrimmed"]
            )
            targets["fastqc"][trimmer] += expand(
                os.path.join(dir["reports"], trimmer, "{file}"),
                file=samples["reads"][sample_name]["fastqc_targets"]
            )
