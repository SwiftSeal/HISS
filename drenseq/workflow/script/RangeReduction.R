#!/usr/bin/env Rscript

# Import required libraries
library(Biostrings)

# Parse CLI arguments
args <- commandArgs(TRUE)
input_path <- args[1]
output_path <- args[2]
flanking_region <- as.numeric(args[3])
reference_headers_path <- args[4]
reference_fasta_path <- args[5]

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
coordinates <- convert_to_strand_positive(blast_results$start,
blast_results$end)
blast_results$start <- coordinates[[1]]
blast_results$end <- coordinates[[2]]

# Extract all regions with overlapping bait sequences and putative NLRs
bed_file <- data.frame(IRanges())

for (c in contig_names) {
    filtered <- blast_results[blast_results$contig == c, ]
    blast_range <- IRanges(start = filtered$start, end = filtered$end)
    blast_range_plus <- blast_range + flanking_region
    final_regions <- IRanges(reduce(blast_range_plus))
    contig_name <- rep(c, length(final_regions))
    end_region <- final_regions@start + final_regions@width - 1
    start_region <- final_regions@start - 1
    start_region <- ifelse(start_region < 0, 0, start_region)
    contig_length <- width(fasta[c])
    end_region <- ifelse(end_region > contig_length, contig_length, end_region)
    extract <- data.frame(contig_name, start_region, end_region)
    bed_file <- rbind(bed_file, extract)
    }

# Write out bed file

write.table(bed_file, output_path, sep = "\t", row.names = FALSE,
col.names = FALSE,
quote = FALSE)
