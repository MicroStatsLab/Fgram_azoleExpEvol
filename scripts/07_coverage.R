library(here)
library(data.table)

Coverage <- fread(here("Fgram_coverage.txt"), sep="\t", header=T)
Coverage <- as.data.frame(Coverage)
Coverage <- split(Coverage, Coverage$Chr)

# how long is each chromosome?
lapply(Coverage, function(x) length(t(x[,1])))

# Renamed bin function
calculate_bins <- function(ddn, line, len = 10000) {
  line.ddn <- lapply(ddn, "[", c(1, 2, line))
  bin_cov <- lapply(line.ddn, function(chrom_data) {
    chrom_data$bin <- cut(chrom_data$locus, breaks = seq(0, max(chrom_data$locus), by = len), labels = FALSE)
    tapply(chrom_data[[3]], chrom_data$bin, mean, na.rm = TRUE)
  })
  names(bin_cov) <- names(ddn)
  return(bin_cov)
}

# Note that "scaffolds" in the 233423 genome in Mycocosm are not numbered the same way as the 
# chromosomes in the PH1 reference genome in NCBI.
# Scaffold 1 = Chromosome 1
# Scaffold 2 = Chromosome 2
# Scaffold 3 = Chromosome 4
# Scaffold 4 = Chromosome 3
# Changed the ordering of the loop statement to plot in Chromosome order.
# Also have to manually set the alternating red and blue colours, below.
SWline <- function(bin){
  nm <-deparse(substitute(bin))
  # calculate the number of positions in the first chromosome
  x0 <- length(bin[[1]])
  #stand <- mean(unlist(bin[[1]]))
  stand <- mean(unlist(bin[[1]]))
  #stand <- mean(subset(Flu, coverage<500)$coverage)
  plot(1:    x0,  unlist(bin[[1]])/stand,  type="l", col="red", xlim=c(0, length(unlist(bin))), xaxt="n", yaxt="n", xlab="", ylab="", ylim=c(0, 3.5))
  for (i in c(2,4,3)){
    x1 <- length(bin[[i]])+x0-1
    x <- x0:x1
    stand <- median(unlist(bin[[1]]))
    #stand <- median(median(unlist(bin[[1]])),median(unlist(bin[[2]])),median(unlist(bin[[3]])),median(unlist(bin[[4]])),median(unlist(bin[[5]])),median(unlist(bin[[6]])),median(unlist(bin[[7]])),median(unlist(bin[[8]])),median(unlist(bin[[9]])),median(unlist(bin[[10]])),median(unlist(bin[[11]])),median(unlist(bin[[12]])),median(unlist(bin[[13]])))
    #stand <- mean(mean(unlist(bin[[1]])),mean(unlist(bin[[2]])),mean(unlist(bin[[3]])),mean(unlist(bin[[4]])),mean(unlist(bin[[5]])),mean(unlist(bin[[6]])),mean(unlist(bin[[7]])),mean(unlist(bin[[8]])),mean(unlist(bin[[9]])),mean(unlist(bin[[10]])),mean(unlist(bin[[11]])),mean(unlist(bin[[12]])),mean(unlist(bin[[13]])))
    points(c(x0:x1), unlist(bin[[i]]/stand), type="l", col=col[i])
    x0 <- x1
  }
  mtext(nm, side=3, adj=0.01, cex=0.7)  
  abline(h=1, lty=2)
  abline(h=2, lty=2)
  abline(h=3, lty=2)
  abline(h=4, lty=2)
  #axis(1,at=c(49,148,254,375,509,671,862,1067,1282,1511,1761,2037,2323),cex.axis=0.5,labels=FALSE)
}
col <- c("red", "blue", "blue", "red")

# 5. Create normalized data for each sample
ANC <- calculate_bins(Coverage, 3)
DMS1 <- calculate_bins(Coverage, 4)
DMS2 <- calculate_bins(Coverage, 5)
DMS3 <- calculate_bins(Coverage, 6)
DMS4 <- calculate_bins(Coverage, 7)
CMB1 <- calculate_bins(Coverage, 8)
CMB2 <- calculate_bins(Coverage, 9)
CMB3 <- calculate_bins(Coverage, 10)
CMB4 <- calculate_bins(Coverage, 11)
PTZ1 <- calculate_bins(Coverage, 12)
PTZ2 <- calculate_bins(Coverage, 13)
PTZ3 <- calculate_bins(Coverage, 14)
PTZ4 <- calculate_bins(Coverage, 15)
TBF1 <- calculate_bins(Coverage, 16)
TBF2 <- calculate_bins(Coverage, 17)
TBF3 <- calculate_bins(Coverage, 18)
TBF4 <- calculate_bins(Coverage, 19)

# 6. visualize the sample
png(file="Supplementary_FigureS1.png", width=1000, height=1200, pointsize = 24)
par(mfrow=c(10, 2), mar=c(0.5, 1, 1.5, 2), oma=c(2, 1, 1, 1))
SWline(ANC)
axis(2, las=2, at=c(1, 2, 3))
SWline(ANC)
SWline(DMS1)
axis(2, las=2, at=c(1, 2, 3))
SWline(DMS2)
SWline(DMS3)
axis(2, las=2, at=c(1, 2, 3))
SWline(DMS4)
SWline(PTZ1)
axis(2, las=2, at=c(1, 2, 3))
SWline(PTZ2)
SWline(PTZ3)
axis(2, las=2, at=c(1, 2, 3))
SWline(PTZ4)
SWline(TBF1)
axis(2, las=2, at=c(1, 2, 3))
SWline(TBF2)
SWline(TBF3)
axis(2, las=2, at=c(1, 2, 3))
SWline(TBF4)
SWline(CMB1)
axis(2, las=2, at=c(1, 2, 3))
SWline(CMB2)
SWline(CMB3)
axis(2, las=2, at=c(1, 2, 3))
axis(1, at=length(ANC[[1]])/2, label = "Chr1")
axis(1, at=length(ANC[[1]])+length(ANC[[2]])/2, label = "Chr2")
axis(1, at=length(ANC[[1]])+length(ANC[[2]])+length(ANC[[3]])/2, label = "Chr3")
axis(1, at=length(ANC[[1]])+length(ANC[[2]])+length(ANC[[3]])+length(ANC[[4]])/2, label = "Chr4")
SWline(CMB4)
axis(1, at=length(ANC[[1]])/2, label = "Chr1")
axis(1, at=length(ANC[[1]])+length(ANC[[2]])/2, label = "Chr2")
axis(1, at=length(ANC[[1]])+length(ANC[[2]])+length(ANC[[3]])/2, label = "Chr3")
axis(1, at=length(ANC[[1]])+length(ANC[[2]])+length(ANC[[3]])+length(ANC[[4]])/2, label = "Chr4")
dev.off()
