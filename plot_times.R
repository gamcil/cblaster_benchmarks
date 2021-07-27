library(ggplot2)
library(tidyr)

# Read in data
data <- read.table(file="times.csv", sep=",", header=TRUE)

# Convert to long format, with single value per row
data2 <- tidyr::pivot_longer(
  data,
  cols=c(cblaster, MultiGeneBlast),
  names_to="Tool",
  values_to="Values"
)

# Plot 
ggplot(data2, aes(x=Total.genes, y=Values, color=Tool, shape=Tool)) +
  labs(colour="Tool") +
  geom_point(size=2) +
  stat_smooth(
    data=subset(data2, Tool == "MultiGeneBlast"),
    mapping=aes(x=Total.genes, y=Values),
    method="nls",
    formula=y ~ a * exp(b * x),
    se=FALSE,
    method.args=list(start=list(a=1, b=1), control=list(maxiter=150))
  ) +
  stat_smooth(
    data=subset(data2, Tool == "cblaster"),
    mapping=aes(x=Total.genes, y=Values),
    method="lm",
    formula=y ~ x,
    se=FALSE
  ) +
  scale_x_continuous("Total genes", breaks=c(5, 10, 15, 20, 25)) +
  scale_y_continuous("Time elapsed (s)") +
  theme_classic(base_size = 15) +
  theme(legend.position = c(0.1, 0.9))
