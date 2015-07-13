library(ggplot2)
library(data.table)
library(ggthemes)
library(uaparser)

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

# User agent analysis
ua_data <- read.delim("iran_ua_data.tsv", as.is = TRUE, header = TRUE)
ua_data <- data.table(date = as.Date(paste(ua_data$year, ua_data$month, ua_data$day, sep = "-")),
                      user_agent = ua_data$user_agent,
                      events = ua_data$pageviews)
ua_data <- ua_data[complete.cases(ua_data),]

agents <- parse_agents(ua_data$user_agent)
browsers <- data.table(date = ua_data$date, browser = paste(agents$browser, agents$browser_major),
                       pageviews = ua_data$events)
browsers <- browsers[,j=list(pageviews = sum(pageviews)), by = c("date","browser")]
browsers <- browsers[order(browsers$pageviews, decreasing = TRUE),]

prominent_browsers <- browsers$browser[browsers$date == as.Date("2015-06-08")][1:10]
prominent_browsers <- browsers[browsers$browser %in% prominent_browsers,]
prominent_browsers$date <- as.character(prominent_browsers$date)
prominent_browsers$date[prominent_browsers$date == "2015-06-08"] <- "pre-switchover"
prominent_browsers$date[!prominent_browsers$date == "pre-switchover"] <- "post-switchover"
ggsave(plot = ggplot(prominent_browsers, aes(x = reorder(browser, pageviews), y = pageviews, fill = factor(date))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Top browsers for Pageviews from Iranian IP addresses") + coord_flip(),
       file = "ua_data.svg")
