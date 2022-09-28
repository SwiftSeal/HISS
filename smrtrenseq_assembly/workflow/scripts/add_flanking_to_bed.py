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
    parser.add_argument('--flank', required=True,
                        help='Number of bases for flanking regions')
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

# Prepare function to get new start & end of genes


def get_positions(bed: list, lengths: list, flank: int):
    contig_dict = get_lengths(lengths)
    bed_dict = defaultdict(list)
    for line in bed:
        line = line.rstrip()
        split_line = line.split('\t')
        contig = split_line[0]
        start = split_line[1]
        end = split_line[2]
        nlr = split_line[3]
        score = split_line[4]
        strand = split_line[5]
        lower = start - flank
        upper = end + flank
        length = contig_dict[contig]
        if lower <= 0:
            lower = 1
        if upper > length:
            upper = length
        list_to_write = [str(contig), str(lower), str(upper), str(nlr),
                         str(score), str(strand)]
        bed_dict[str(nlr)] = list_to_write
    return bed_dict

# Prepare function to write out file


def output(bed: list, lengths: list, flank: int, out_file):
    bed_dict = get_positions(bed, lengths, flank)
    for nlr in bed_dict.keys():
        list_to_write = bed_dict[str(nlr)]
        string_to_write = '\t'.join(list_to_write)
        out_file.write(string_to_write)
        out_file.write('\n')
    out_file.close()

# Prepare main function


def main():
    args = parse_args()
    bed = open(args.input_bed).readlines()
    lengths = open(args.input_lengths).readlines()
    flank = args.flank
    out_file = open(args.output, 'w')
    output(bed, lengths, flank, out_file)


if __name__ == '__main__':
    main()
