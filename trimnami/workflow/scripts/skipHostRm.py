import gzip
import shutil


def gzip_file(input_file, output_file):
    """
    Check if a file is gzipped and either zip it or copy the file

    Args:
        input_file (str): filepath of input file (gzipped or not)
        output_file (str): filepath of output gzipped file
    """
    is_gzipped = input_file.endswith('.gz')
    if is_gzipped:
        shutil.copyfile(input_file, output_file)
    else:
        with open(input_file, 'rb') as f_in:
            with gzip.open(output_file, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)


def main(**kwargs):
    gzip_file(kwargs["input_r1"], kwargs["output_r1"])
    if "input_r2" in kwargs.keys():
        gzip_file(kwargs["input_r2"], kwargs["output_r2"])
    if "output_s" in kwargs.keys():
        open(kwargs["output_s"], "w").close()


if __name__ == "__main__":
    if snakemake.params.is_paired:
        main(
            input_r1=snakemake.input.r1,
            input_r2=snakemake.input.r2,
            output_r1=snakemake.output.r1,
            output_r2=snakemake.output.r2,
            output_s=snakemake.output.s
        )
    else:
        main(
            input_r1=snakemake.input.r1,
            output_r1=snakemake.output.r1,
        )
