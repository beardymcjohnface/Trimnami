import subprocess
from pathlib import Path

import pytest


TEST_ROOTDIR = Path(__file__).parent
EXEC_ROOTDIR = Path(__file__).parent.parent


@pytest.fixture(scope="session")
def tmp_dir(tmpdir_factory):
    return tmpdir_factory.mktemp("tmp")


@pytest.fixture(autouse=True)
def workingdir(tmp_dir, monkeypatch):
    """set the working directory for all tests"""
    monkeypatch.chdir(tmp_dir)


def exec_command(cmnd, stdout=subprocess.PIPE, stderr=subprocess.PIPE):
    """executes shell command and returns stdout if completes exit code 0
    Parameters
    ----------
    cmnd : str
      shell command to be executed
    stdout, stderr : streams
      Default value (PIPE) intercepts process output, setting to None
      blocks this."""

    proc = subprocess.Popen(cmnd, shell=True, stdout=stdout, stderr=stderr)
    out, err = proc.communicate()
    if proc.returncode != 0:
        raise RuntimeError(f"FAILED: {cmnd}\n{err}")
    return out.decode("utf8") if out is not None else None


def test_trimnami_cli(tmp_dir):
    exec_command("trimnami -v")
    exec_command("trimnami -h")
    exec_command("trimnami run -h")
    exec_command("trimnami config -h")


def test_trimnami_commands(tmp_dir):
    exec_command("trimnami test --threads 1 -n prinseq fastp roundAB notrim nanopore")
    exec_command("trimnami test --threads 1 -n --fastqc")
    exec_command("trimnami test --threads 1 -n --subsample 1k")
    exec_command("trimnami test --threads 1 -n --subsample 1k --fastqc")
    exec_command("trimnami testhost --threads 1 -n prinseq fastp roundAB notrim nanopore")
    exec_command("trimnami testhost --threads 1 -n --fastqc")
    exec_command("trimnami testhost --threads 1 -n --subsample 1k")
    exec_command("trimnami testhost --threads 1 -n --subsample 1k --fastqc")
    exec_command("trimnami testnp --threads 1 -n")
    exec_command("trimnami testnp --threads 1 -n --subsample 1k")
    exec_command("trimnami testnp --threads 1 -n --fastqc")
    exec_command("trimnami testnp --threads 1 -n --subsample 1k --fastqc")
    exec_command("trimnami config")
    exec_command("trimnami citation")
