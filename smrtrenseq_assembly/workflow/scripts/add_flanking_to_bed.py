#!/usr/bin/env python3

# Script to add flanking regions to NLR Annotator bed file

# Import python modules

from collections import defaultdict
import argparse

# Prepare function to parse CLI arguments


def parse_args():
    parser = argparse.ArgumentParser(description='Add flanking seq to bed')
    parser.add_argument('--input_bed', required=True,
                        help='Input file of predicted NLRs in bed format')
    parser.add_argument('--input_lengths', required=True,
                        help='Input file of contig lengths')
    parser.add_argument('--output', required=True,
                        help='Output file in bed format with flanking added')
    return parser.parse_args()


# Prepare function to get contig lengths:


def get_lengths(lengths: list):
    contig_dict = defaultdict(float)
    for line in lengths:
        line = line.rstrip()
        split_line = line.split('\t')
        contig = split_line[0]
        length = split_line[1]
        contig_dict[contig] = length
    return contig_dict
