import os
from setuptools import setup, find_packages


def get_version():
    with open(
        os.path.join(
            os.path.dirname(os.path.realpath(__file__)),
            "trimnami",
            "trimnami.VERSION",
        )
    ) as f:
        return f.readline().strip()
    

def get_description():
    with open("README.md", "r") as fh:
        long_description = fh.read()
    return long_description


def get_data_files():
    data_files = [(".", ["README.md"])]
    return data_files


CLASSIFIERS = [
    "Environment :: Console",
    "Environment :: MacOS X",
    "Intended Audience :: Science/Research",
    "License :: OSI Approved :: MIT license",
    "Natural Language :: English",
    "Operating System :: POSIX :: Linux",
    "Operating System :: MacOS :: MacOS X",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Topic :: Scientific/Engineering :: Bio-Informatics",
]

setup(
    name="trimnami",
    packages=find_packages(),
    url="https://github.com/beardymcjohnface/Trimnami",
    python_requires=">=3.8",
    description="Trim lots of metagenomics samples all at once.",
    long_description=get_description(),
    long_description_content_type="text/markdown",
    version=get_version(),
    author="Michael Roach",
    author_email="beardymcjohnface@gmail.com",
    data_files=get_data_files(),
    py_modules=["trimnami"],
    install_requires=[
        "snaketool-utils>=0.0.3",
        "snakemake>=7.14.0",
        "pyyaml>=6.0",
        "Click>=8.1.3",
        "metasnek>=0.0.5",
    ],
    entry_points={
        "console_scripts": [
            "trimnami=trimnami.__main__:main"
        ]
    },
    include_package_data=True,
)
