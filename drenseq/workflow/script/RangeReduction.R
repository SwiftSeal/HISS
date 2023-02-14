#!/usr/bin/env Rscript

# Import required libraries

library(Biostrings)

# Parse CLI arguments

args <- commandArgs(TRUE)
input <- args[1]
output <- args[2]
flanking_region <- args[3]
reference_headers <- args[4]
reference_fasta <- args[5]

# Read in input BLAST results

infile <- read.csv(input, header = FALSE, sep = "\t")
infile <- infile[, c(2, 9, 10)]
colnames(infile) <- c("contig", "start", "end")

# Check all input genes have at least one blast hit from the baits

contig_names <- unique(infile$contig)
targets_file <- read.csv(reference_headers, header = TRUE)
input_headers <- unique(targets_file$gene)
fasta <- readDNAStringSet(reference_fasta)

if (all(input_headers %in% contig_names)) {
    print("All sequences have a bait hit")
} else {
    print("At least one of your sequences does not have a bait hit from blast.")
    print("The workflow will fail if allowed to continue.")
    print("The workflow will now be ended.")
    print("Check the input sequences and remove those that have no bait hits")
    quit(save = "no", status = 10)
}

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

contigs <- as.list(unique(infile$contig))

bedfile <- data.frame(IRanges())

for (c in contigs) {
    filtered <- swapped[swapped$contig == c, c(1, 2, 3)]
    blastrange <- IRanges(start = filtered$start, end = filtered$end)
    flank <- as.numeric(flanking_region)
    blastrangeplus <- blastrange + flank
    finalregions <- IRanges(reduce(blastrangeplus))
    contigname <- rep(c, length(finalregions))
    endregion <- finalregions@start + finalregions@width - 1
    startregion <- finalregions@start - 1
    if (startregion < 0) {
        startregion <- 0
    }
    contig_length <- width(fasta[c])
    if (endregion > contig_length) {
        endregion <- contig_length
    }
    extract <- data.frame(contigname, startregion, endregion)
    bedfile <- rbind(bedfile, extract)
    }

# Write out bed file

write.table(bedfile, output, sep = "\t", row.names = FALSE, col.names = FALSE,
quote = FALSE)
