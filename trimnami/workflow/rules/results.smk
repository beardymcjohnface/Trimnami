rule save_output:
    """Save the final trimmed output file"""
    input:
        os.path.join(dir["temp"], "{dir}", "{file}")
    output:
        os.path.join(dir["results"], "{dir}", "{file}")
    localrule: True
    shell:
        "ln {input} {output}"