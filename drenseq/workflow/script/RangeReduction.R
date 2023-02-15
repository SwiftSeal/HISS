#!/usr/bin/env Rscript

# Import required libraries

library(Biostrings)

# Parse CLI arguments

args <- commandArgs(TRUE)
input_path <- "testdata/baits_blast.txt"
output_path <- "test_output.txt"
flanking_region <- "200"
reference_headers_path <- "testdata/reference_headers_contigs.txt"
reference_fasta_path <- "testdata/Vitabella_candidates.fa"

# Read in input BLAST results
blast_results <- read.csv(input_path, header = FALSE, sep = "\t")
blast_results <- blast_results[, c(2, 9, 10)]
colnames(blast_results) <- c("contig", "start", "end")

# Check all input genes have at least one blast hit from the baits
contig_names <- unique(blast_results$contig)

reference_headers <- read.csv(reference_headers_path, header = FALSE)
input_headers <- unique(reference_headers$V1)
fasta <- readDNAStringSet(reference_fasta)

if (all(input_headers %in% contig_names)) {
    print("All sequences have a bait hit")
} else {
    stop("At least one of your sequences does not have a bait hit from blast.\n
    The workflow will fail if allowed to continue.\n
    The workflow will now be ended.\n
    Check the input sequences and remove those that have no bait hits")
}


# Ensure all starts and stops are relative to the + strand
convert_to_strand_positive <- function(start, end) {
  starts <- ifelse(start < end, start, end)
  ends <- ifelse(start < end, end, start)
  return(list(starts, ends))
}
coordinates <- convert_to_strand_positive(blast_results$start, blast_results$end)
blast_results$start <- coordinates[[1]]
blast_results$end <- coordinates[[2]]

# Extract all regions with overlapping bait sequences and putative NLRs
contigs <- unique(blast_results$contig)
bedfile <- data.frame(IRanges())

for (c in contigs) {
    filtered <- blast_results[blast_results$contig == c, c(1, 2, 3)]
    blastrange <- IRanges(start = filtered$start, end = filtered$end)
    flank <- as.numeric(flanking_region)
    blastrangeplus <- blastrange + flank
    finalregions <- IRanges(reduce(blastrangeplus))
    contigname <- rep(c, length(finalregions))
    endregion <- finalregions@start + finalregions@width - 1
    startregion <- finalregions@start - 1
    startregion <- ifelse(startregion < 0, 0, startregion)
    contig_length <- width(fasta[c])
    endregion <- ifelse(endregion > contig_length, contig_length,
    endregion)
    extract <- data.frame(contigname, startregion, endregion)
    bedfile <- rbind(bedfile, extract)
    }

# Write out bed file

write.table(bedfile, output, sep = "\t", row.names = FALSE, col.names = FALSE,
quote = FALSE)
