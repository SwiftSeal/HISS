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
    parser.add_argument('--input_fasta', required=True,
                        help='Input fasta file of assembled contigs')
    parser.add_argument('--output', required=True,
                        help='Output file in bed format with flanking added')
    return parser.parse_args()
