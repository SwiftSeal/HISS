library(ggplot2)
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

agrenseq <- read.table(args[1], sep="\t")
threshold <- strtoi(args[2])

filtered <- agrenseq %>%
  filter(V3 >= threshold) %>%
  select(V1) %>%
  distinct()

agrenseq$passed <- agrenseq$V1 %in% filtered$V1

agrenseq = agrenseq %>%
  arrange(desc(passed))

p <- ggplot(data = agrenseq, aes(x = V2, y = V3, size = V4)) +
  geom_point(aes(col = passed)) +
  geom_hline(yintercept = threshold, col = "#f44336", linetype = "dashed") +
  xlab("Contig") +
  ylab("Association score") +
  labs(title = args[3]) +
  labs(size="Kmers") +
  scale_color_manual(values = c("#000000", "#f44336")) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = NA),
        axis.line = element_line(colour = "black"),
        legend.key = element_blank())

write.table(filtered, file = args[4], quote = FALSE, sep = "\t", col.names = FALSE, row.names = FALSE)
ggsave(args[5], width = 5, height = 2)
