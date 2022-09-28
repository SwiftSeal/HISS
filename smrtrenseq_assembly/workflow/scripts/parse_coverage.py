#!/usr/bin/env python3

# Script to get useful values from output of samtools bedcov

# Import python modules

import argparse
from collections import defaultdict

# Prepare function to parse CLI arguments


def parse_args():
    parser = argparse.ArgumentParser(description='Parse samtools bedcov file')
    parser.add_argument('--input', required=True,
                        help='Output of samtools bedcov to be parsed')
    parser.add_argument('--output', required=True,
                        help='Location to write parsed coverage results')
    return parser.parse_args()

# Prepare function to parse files and prepare data structures


def load_file(input: list):
    coverage_dict = defaultdict(float)
    for line in input:
        split_line = line.split()
        gene_ID = split_line[3]
        start = split_line[1]
        stop = split_line[2]
        coverage = split_line[6]
        length = float(stop) - float(start) + 1
        average_coverage = float(coverage) / length
        coverage_dict[gene_ID] = average_coverage
    return(coverage_dict)

# Prepare function to write out parsed coverage


def output(input: str, outfile):
    coverage_dict = load_file(input)
    for gene in coverage_dict.keys():
        list_to_write = [gene, str(coverage_dict[gene])]
        string_to_write = '\t'.join(list_to_write)
        outfile.write(string_to_write)
        outfile.write('\n')

# Prepare main function


def main():
    args = parse_args()
    input = open(args.input).readlines()
    outfile = open(args.output, 'w')
    output(input, outfile)


if __name__ == '__main__':
    main()
