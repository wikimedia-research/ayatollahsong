library(ggplot2)
library(data.table)
library(ggthemes)
options(scipen = 500)

# Read in and format data
data <- read.delim("iran_data.tsv", as.is = TRUE, header = TRUE)
data <- data[1:(nrow(data)-2),]
data <- data.table(date = as.Date(paste(data$year, data$month, data$day, sep = "-")),
                   domain = gsub(x = data$uri_host, pattern = ".m.", fixed = TRUE, replacement = "."),
                   type = ifelse(as.logical(data$is_https) == TRUE, "https", "http"),
                   events = data$X_c6)

# Work out really basic pageviews things

by_day <- data[,j=list(pageviews = sum(events)), by = c("date","type")]
ggsave(plot = ggplot(by_day, aes(x = date, y = pageviews, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "HTTP and HTTPS Wikimedia pageviews from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_pageviews.svg"
)

# 2015-06-12 - 2015-06-17 killed it entirely

# Just farsi?

fa_by_day <- data[data$domain == "fa.wikipedia.org",j=list(pageviews = sum(events)), by = c("date","type")]
by_day <- data[,j=list(pageviews = sum(events)), by = c("date","type")]

ggsave(plot = ggplot(by_day, aes(x = date, y = pageviews, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "fa.wikipedia.org pageviews from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_fa_pageviews.svg"
)

project_data <- data
project_data$domain <- gsub(x = project_data$domain, pattern = ".m.", fixed = TRUE, replacement = ".")
top_projects <- project_data[,j=list(pageviews = sum(events)), by = c("domain")]
top_projects <- top_projects[order(top_projects$pageviews, decreasing = T)]
