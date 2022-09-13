#!/mnt/shared/scratch/tadams/apps/conda/bin/python

# Script to convert NLR Annotator output to bed file to assess coverage
# Ensure you are running python3.10 as this uses a case statement

# Import python modules

import argparse
from collections import defaultdict

# Prepare function to parse CLI arguments


def parse_args():
    parser = argparse.ArgumentParser(description='Convert NLR output to bed')
    parser.add_argument('--input', required=True,
                        help='Input file of predicted NLRs')
    parser.add_argument('--output', required=True,
                        help='Output file in bed format')
    return parser.parse_args()

# Preare function to parse file to data structure


def load_file(input: list):
    output_dict = defaultdict(str)
    for line in input:
        line = line.rstrip()
        split_line = line.split('\t')
        nlr_type = split_line[2]
        match nlr_type:
            case "complete (pseudogene)" | "complete":
                contig = split_line[0]
                start = int(split_line[3]) - 1
                end = split_line[4]
                gene_ID = split_line[1]
                score = 0
                strand = split_line[5]
                list_to_write = [contig, str(start), str(end), gene_ID,
                                 str(score), str(strand)]
                string_to_write = "\t".join(list_to_write)
                output_dict[gene_ID] = string_to_write
    return output_dict

# Prepare function to write output to bed file


def output(input: str, out_file):
    output_dict = load_file(input)
    for gene in output_dict.keys():
        out_file.write(output_dict[gene])
        out_file.write('\n')

# Prepare main function to convert file


def main():
    args = parse_args()
    input = open(args.input).readlines()
    out_file = open(args.output, 'w')
    output(input, out_file)


if __name__ == '__main__':
    main()
