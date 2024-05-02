"""
Entrypoint for Trimnami
"""

import os
import click

from snaketool_utils.cli_utils import (
    OrderedCommands,
    run_snakemake,
    initialise_config,
    echo_click,
)


def snake_base(rel_path):
    return os.path.join(os.path.dirname(os.path.realpath(__file__)), rel_path)


def get_version():
    with open(snake_base("trimnami.VERSION"), "r") as f:
        version = f.readline()
    return version


def print_citation():
    with open(snake_base("trimnami.CITATION"), "r") as f:
        for line in f:
            echo_click(line)


def default_to_output(ctx, param, value):
    """Callback for click options; places value in output directory unless specified"""
    if param.default == value:
        return os.path.join(ctx.params["output"], value)
    return value


def common_options(func):
    """General Snakemake-related options"""
    options = [
        click.option(
            "--output",
            help="Output directory",
            type=click.Path(dir_okay=True, writable=True, readable=True),
            default="trimnami.out",
            show_default=True,
        ),
        click.option(
            "--configfile",
            default="trimnami.config.yaml",
            show_default=False,
            callback=default_to_output,
            help="Custom config file [default: (outputDir)/trimnami.config.yaml]",
        ),
        click.option(
            "--system_config",
            default=snake_base(os.path.join("config", "config.yaml")),
            type=click.Path(),
            hidden=True,
        ),
        click.option(
            "--threads", help="Number of threads to use", default=8, show_default=True
        ),
        click.option(
            "--use-conda/--no-use-conda",
            default=True,
            help="Use conda for Snakemake rules",
            show_default=True,
        ),
        click.option(
            "--conda-prefix",
            default=snake_base(os.path.join("workflow", "conda")),
            help="Custom conda env directory",
            type=click.Path(),
            show_default=False,
        ),
        click.option(
            "--workflow-profile",
            default="trimnami.profile",
            show_default=False,
            callback=default_to_output,
            help="Custom config file [default: (outputDir)/trimnami.profile/]",
        ),
        click.option(
            "--system-workflow-profile",
            default=snake_base(os.path.join("config", "profile", "config.yaml")),
            help="Default workflow profile",
            hidden=True,
        ),
        click.option(
            "--log",
            default="trimnami.log",
            callback=default_to_output,
            hidden=True,
        ),
        click.argument("snake_args", nargs=-1),
    ]
    for option in reversed(options):
        func = option(func)
    return func


def run_options(func):
    """Options related to Trmnami pipeline"""
    options = [
        click.option(
            "--host",
            help="Host genome fasta for filtering",
            show_default=False,
            required=False,
        ),
        click.option(
            "--minimap",
            help="Minimap preset",
            default="sr",
            show_default=True,
            type=click.Choice(["sr", "map-pb", "map-ont", "map-hifi"]),
        ),
        click.option(
            "--fastqc/--no-fastqc",
            default=False,
            help="Run fastqc on trimmed and untrimmed reads",
            show_default=True,
        ),
        click.option(
            "--fasta/--no-fasta",
            default=False,
            help="Output fasta format files instead of fastq",
            show_default=True,
        ),
        click.option(
            "--subsample/--no-subsample",
            default=None,
            help="Perform subsampling (set in config file)",
            show_default=False,
        ),
    ]
    for option in reversed(options):
        func = option(func)
    return func


@click.group(
    cls=OrderedCommands, context_settings=dict(help_option_names=["-h", "--help"])
)
@click.version_option(get_version(), "-v", "--version", is_flag=True)
def cli():
    """Trim lots of metagenomics samples all at once.
    \b
    For more options, run:
    trimnami command --help"""
    pass


def print_splash():
    click.echo(
        """\b
████████╗██████╗ ██╗███╗   ███╗███╗   ██╗ █████╗ ███╗   ███╗██╗
╚══██╔══╝██╔══██╗██║████╗ ████║████╗  ██║██╔══██╗████╗ ████║██║
   ██║   ██████╔╝██║██╔████╔██║██╔██╗ ██║███████║██╔████╔██║██║
   ██║   ██╔══██╗██║██║╚██╔╝██║██║╚██╗██║██╔══██║██║╚██╔╝██║██║
   ██║   ██║  ██║██║██║ ╚═╝ ██║██║ ╚████║██║  ██║██║ ╚═╝ ██║██║
   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
"""
    )


help_msg_extra = """
\b
CLUSTER EXECUTION:
trimnami run ... --profile [profile]
For information on Snakemake profiles see:
https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles
\b
RUN EXAMPLES:
Required:           trimnami run --reads [file]
Specify threads:    trimnami run ... --threads [threads]
Disable conda:      trimnami run ... --no-use-conda 
Change defaults:    trimnami run ... --snake-default="-k --nolock"
Add Snakemake args: trimnami run ... --dry-run --keep-going --touch
Specify targets:    trimnami run ... all print_targets
Available targets:
    fastp           Trim reads with fastp (default)
    prinseq         Trim reads with prinseq++
    roundAB         Trim round A/B viral metagenome reads
    cutadapt        Trim with cutadapt (support for FASTA input)
    filtlong        Filter out short-length longreads
    notrim          Skip read trimming
    print_trimmers  List available trimming modules
"""


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@run_options
@common_options
@click.option("--reads", help="Input file/directory", type=str, required=True)
def run(**kwargs):
    """Run Trimnami"""

    merge_config = {"trimnami": {"args": kwargs}}

    run_snakemake(
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        **kwargs
    )


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@run_options
@common_options
def test(**kwargs):
    """Run Trimnami with the test dataset"""

    merge_config = {"trimnami": {"args": kwargs}}

    merge_config["trimnami"]["args"]["reads"] = snake_base(os.path.join("test_data"))
    merge_config["trimnami"]["args"]["host"] = None
    merge_config["trimnami"]["args"]["minimap"] = "sr"

    run_snakemake(
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        **kwargs
    )


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@run_options
@common_options
def testhost(**kwargs):
    """Test Trimnami with the test SR dataset and test host"""

    merge_config = {"trimnami": {"args": kwargs}}

    merge_config["trimnami"]["args"]["reads"] = snake_base(os.path.join("test_data"))
    merge_config["trimnami"]["args"]["host"] = snake_base(
        os.path.join("test_data", "ref.fna")
    )
    merge_config["trimnami"]["args"]["minimap"] = "sr"

    run_snakemake(
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        **kwargs
    )


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@run_options
@common_options
def testnp(**kwargs):
    """Test Trimnami with the test LR dataset and test host"""

    merge_config = {"trimnami": {"args": kwargs}}

    merge_config["trimnami"]["args"]["reads"] = snake_base(
        os.path.join("test_data", "nanopore")
    )
    merge_config["trimnami"]["args"]["host"] = snake_base(
        os.path.join("test_data", "ref.fna")
    )
    merge_config["trimnami"]["args"]["minimap"] = "map-ont"

    kwargs["snake_args"] = ["filtlong"]

    run_snakemake(
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        **kwargs
    )


@click.command()
@common_options
def config(**kwargs):
    """Copy the system default config file"""
    initialise_config(**kwargs)


@click.command()
def citation(**kwargs):
    """Print the citation(s) for this tool"""
    print_citation()


cli.add_command(run)
cli.add_command(test)
cli.add_command(testhost)
cli.add_command(testnp)
cli.add_command(config)
cli.add_command(citation)


def main():
    print_splash()
    cli()


if __name__ == "__main__":
    main()
