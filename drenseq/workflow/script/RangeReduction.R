#!/usr/bin/env Rscript

# Import required libraries

library(IRanges)

# Parse CLI arguments

args <- commandArgs(TRUE)
input <- args[1]
output <- args[2]
flanking_region <- args[3]
reference_headers <- args[4]

# Read in input BLAST results

infile <- read.csv(input, header = FALSE, sep = "\t")
infile <- infile[, c(2, 9, 10)]
colnames(infile) <- c("contig", "start", "end")

# Check all input genes have at least one blast hit from the baits

contigs <- as.list(unique(infile$contig))
targets_file <- read.csv(reference_headers, header = TRUE)

# Ensure all starts and stops are relative to the + strand

swap_if <- function(a, b, d, missing = NA) {
    c <- a
    end <- ifelse(b > a, b, a)
    start <- ifelse(b <= a, b, c)
    contig <- d
    z <- data.frame(contig, start, end)
    return(z)
    }

swapped <- swap_if(infile$start, infile$end, infile$contig)

# Extract all regions with overlapping bait sequences and putative NLRs

bedfile <- data.frame(IRanges())

for (c in contigs) {
    filtered <- swapped[swapped$contig == c, c(1, 2, 3)]
    blastrange <- IRanges(start = filtered$start, end = filtered$end)
    flank <- as.numeric(flanking_region)
    blastrangeplus <- blastrange + flank
    finalregions <- IRanges(reduce(blastrangeplus))
    contigname <- rep(c, length(finalregions))
    endregion <- finalregions@start + finalregions@width
    extract <- data.frame(contigname, finalregions@start, endregion)
    bedfile <- rbind(bedfile, extract)
    }

# Write out bed file

write.table(bedfile, output, sep = "\t", row.names = FALSE, col.names = FALSE,
quote = FALSE)
