library(ggplot2)
library(data.table)
library(ggthemes)
options(scipen = 500)

#Read in and format data
data <- read.delim("iran_data.tsv", as.is = TRUE, header = TRUE)
data <- data[1:(nrow(data)-2),]
data <- data.table(date = as.Date(paste(data$year, data$month, data$day, sep = "-")),
                   domain = data$uri_host,
                   type = ifelse(as.logical(data$is_https) == TRUE, "https", "http"),
                   events = data$X_c6)

by_day <- data[,j=list(pageviews = sum(events)), by = c("date","type")]

ggsave(plot = ggplot(by_day, aes(x = date, y = pageviews, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "HTTP and HTTPS Wikipedia pageviews from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_pageviews.svg"
)
