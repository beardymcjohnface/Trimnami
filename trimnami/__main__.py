"""
Entrypoint for Trimnami
"""

import os
import click

from .util import (
    snake_base,
    get_version,
    default_to_output,
    copy_config,
    run_snakemake,
    OrderedCommands,
    print_citation,
)


def common_options(func):
    """Common command line args
    Define common command line args here, and include them with the @common_options decorator below.
    """
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
            "--snake-default",
            multiple=True,
            default=[
                "--rerun-incomplete",
                "--printshellcmds",
                "--nolock",
                "--show-failed-logs",
            ],
            help="Customise Snakemake runtime args",
            show_default=True,
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
    click.echo("""
\b
████████╗██████╗ ██╗███╗   ███╗███╗   ██╗ █████╗ ███╗   ███╗██╗
╚══██╔══╝██╔══██╗██║████╗ ████║████╗  ██║██╔══██╗████╗ ████║██║
   ██║   ██████╔╝██║██╔████╔██║██╔██╗ ██║███████║██╔████╔██║██║
   ██║   ██╔══██╗██║██║╚██╔╝██║██║╚██╗██║██╔══██║██║╚██╔╝██║██║
   ██║   ██║  ██║██║██║ ╚═╝ ██║██║ ╚████║██║  ██║██║ ╚═╝ ██║██║
   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
""")


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
    nanopore        Trim nanopore reads
    print_targets   List available targets
"""


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@click.option("--reads", help="Input file/directory", type=str, required=True)
@click.option('--host', help='Host genome fasta for filtering', show_default=False, required=False)
@click.option("--minimap", help="Minimap preset", default="sr", show_default=True,
              type=click.Choice(["map-pb", "map-ont", "map-hifi", "sr"]))
@common_options
def run(reads, output, host, minimap, log, **kwargs):
    """Run Trimnami"""
    # Config to add or update in configfile
    merge_config = {
        "args": {
            "reads": reads,
            "output": output,
            "host": host,
            "minimap": minimap,
            "log": log
        }
    }

    # run!
    run_snakemake(
        # Full path to Snakefile
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        log=log,
        **kwargs
    )


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@common_options
def test(output, log, **kwargs):
    """Run Trimnami with the test dataset"""
    # Config to add or update in configfile
    merge_config = {
        "args": {
            "reads": snake_base(os.path.join("test_data")),
            "host": None,
            "output": output,
            "minimap": "sr",
            "log": log
        }
    }

    # run!
    run_snakemake(
        # Full path to Snakefile
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        log=log,
        **kwargs
    )


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@common_options
def testhost(output, log, **kwargs):
    """Run Trimnami with the test dataset and test host"""
    # Config to add or update in configfile
    merge_config = {
        "args": {
            "reads": snake_base(os.path.join("test_data")),
            "host": snake_base(os.path.join("test_data", "ref.fna")),
            "output": output,
            "minimap": "sr",
            "log": log
        }
    }

    # run!
    run_snakemake(
        # Full path to Snakefile
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        log=log,
        **kwargs
    )


@click.command(
    epilog=help_msg_extra,
    context_settings=dict(
        help_option_names=["-h", "--help"], ignore_unknown_options=True
    ),
)
@common_options
def testnp(output, log, snake_args, **kwargs):
    """Run Trimnami with the test dataset and test host"""
    # Config to add or update in configfile
    merge_config = {
        "args": {
            "reads": snake_base(os.path.join("test_data", "nanopore")),
            "host": snake_base(os.path.join("test_data", "ref.fna")),
            # "host": None,
            "output": output,
            "minimap": "map-ont",
            "log": log
        }
    }

    # run!
    run_snakemake(
        # Full path to Snakefile
        snakefile_path=snake_base(os.path.join("workflow", "Snakefile")),
        merge_config=merge_config,
        log=log,
        snake_args=["nanopore"],
        **kwargs
    )


@click.command()
@common_options
def config(configfile, **kwargs):
    """Copy the system default config file"""
    copy_config(configfile)


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
