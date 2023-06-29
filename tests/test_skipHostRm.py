import os
import gzip
import shutil
import pytest
import gzip

from trimnami.scripts.skipHostRm import gzip_file


@pytest.fixture
def temp_file(tmp_path):
    file_path = tmp_path / "test.txt"
    file_path.write_text("Test content")
    return str(file_path)


@pytest.fixture
def temp_file_gz(tmp_path):
    file_path = tmp_path / "test.gz"
    with gzip.open(file_path, 'wb') as f:
        f.write(b"Test content")
    return str(file_path)


def test_gzip_file(tmp_path, temp_file, temp_file_gz):
    output_file = str(tmp_path / "output.gz")

    gzip_file(temp_file_gz, output_file)

    assert os.path.isfile(output_file)
    assert os.path.getsize(output_file) > 0
    with gzip.open(output_file, 'rb') as f:
        content = f.read().decode('utf-8')
        assert content == "Test content"

    gzip_file(temp_file, output_file)

    assert os.path.isfile(output_file)
    assert os.path.getsize(output_file) > 0
    with gzip.open(output_file, 'rb') as f:
        content = f.read().decode('utf-8')
        assert content == "Test content"
