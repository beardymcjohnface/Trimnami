import pytest
import gzip
import shutil
from unittest import mock

from koverage.scripts.skipHostRm import gzip_file


@pytest.fixture
def temp_dir(tmpdir):
    return str(tmpdir)


@pytest.fixture
def mock_shutil_copyfile(monkeypatch):
    def mock_copyfile(src, dst):
        return

    monkeypatch.setattr(shutil, "copyfile", mock_copyfile)


@pytest.fixture
def mock_open(monkeypatch):
    def mock_open_file(file, mode='r'):
        return mock.mock_open(file, mode)

    monkeypatch.setattr(gzip, "open", mock_open_file)


def test_gzip_file_with_gzipped_input_file(temp_dir, mock_shutil_copyfile):
    input_file = temp_dir + "/input.gz"
    output_file = temp_dir + "/output.gz"

    with open(input_file, "w") as f:
        f.write("test content")

    gzip_file(input_file, output_file)

    assert shutil.copyfile.call_args[0][0] == input_file
    assert shutil.copyfile.call_args[0][1] == output_file


def test_gzip_file_with_non_gzipped_input_file(temp_dir, mock_open):
    input_file = temp_dir + "/input"
    output_file = temp_dir + "/output.gz"

    with open(input_file, "w") as f:
        f.write("test content")

    gzip_file(input_file, output_file)

    assert gzip.open.call_args[0][0] == output_file
    assert gzip.open.call_args[0][1] == "wb"
    assert shutil.copyfileobj.call_args[0][0].name == input_file
    assert shutil.copyfileobj.call_args[0][1].name == output_file
