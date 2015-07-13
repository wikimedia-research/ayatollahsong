library(ggplot2)
library(data.table)

#Read in and format data
data <- read.delim("iran_data.tsv", as.is = TRUE, header = TRUE)
data <- data[1:(nrow(data)-2),]
data <- data.table(date = as.Date(paste(data$year, data$month, data$day, sep = "-")),
                   domain = data$uri_host,
                   is_https = as.logical(data$is_https),
                   events = data$X_c6)

