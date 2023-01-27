#!/usr/bin/env Rscript

# Import required libraries

library(IRanges)

# Parse CLI arguments

args <- commandArgs(TRUE)
input <- args[1]
output <- args[2]
flanking_region <- args[3]

##create input

infile <- read.csv(input, header=FALSE, sep="\t")
infile <-infile[,c(2,9,10)]
colnames(infile) <- c("contig", "start", "end")

##Swap range values so they all go from smallest to largest
swap_if <-  function(a,b,d,missing=NA){
  c <- a
  end <- ifelse(b > a, b,a)
  start <- ifelse(b <=a, b,c)
  contig <- d
  z <- data.frame(contig,start,end)
  return(z)} 


swapped <- swap_if(infile$start, infile$end, infile$contig)

## Create list of all contigs in the file
contigs <- as.list(unique(infile$contig))

##Extract all regions per contig, increase this by 200bp flanking region and reduce overlapping ranges
bedfile=data.frame(IRanges())

for (c in contigs)
  {
  filtered <- swapped[swapped$contig==c,c(1,2,3)]
  blastrange <- IRanges (start=filtered$start, end=filtered$end)
  flank <- as.numeric(flanking_region)
  blastrangeplus <- blastrange + flank
  finalregions <- IRanges(reduce(blastrangeplus))
  
  contigname <- rep(c,length(finalregions))
  endregion <- finalregions@start + finalregions@width
  extract <- data.frame(contigname,finalregions@start,endregion)
  bedfile=rbind(bedfile,extract)
  
}

##create output
write.table(bedfile,output, sep = "\t", row.names = FALSE, col.names=FALSE, quote = FALSE)
