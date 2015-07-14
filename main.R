library(ggplot2)
library(data.table)
library(ggthemes)
library(uaparser)
library(scales)

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
       file = "iran_pageviews.png"
)

# 2015-06-12 - 2015-06-17 killed it entirely

# Just farsi?
fa_by_day <- data[data$domain == "fa.wikipedia.org",j=list(pageviews = sum(events)), by = c("date","type")]

ggsave(plot = ggplot(fa_by_day, aes(x = date, y = pageviews, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "fa.wikipedia.org pageviews from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_fa_pageviews.png"
)

# User agent analysis
ua_data <- read.delim("iran_ua_data.tsv", as.is = TRUE, header = TRUE)
ua_data <- data.table(date = as.Date(paste(ua_data$year, ua_data$month, ua_data$day, sep = "-")),
                      user_agent = ua_data$user_agent,
                      events = ua_data$pageviews)
ua_data <- ua_data[complete.cases(ua_data),]

#Parse the agents and generate the most prominent browsers
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

#Graph the change between the two dates
ggsave(plot = ggplot(prominent_browsers, aes(x = reorder(browser, pageviews), y = pageviews, fill = factor(date))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Top browsers for Pageviews from Iranian IP addresses") + coord_flip(),
       file = "ua_data.png")

#Work out the proportionate drop and graph that
prominent_percentage <- prominent_browsers[j=list(
  percentage_drop = (.SD$pageviews[date == "pre-switchover"] - .SD$pageviews[date == "post-switchover"])/
    .SD$pageviews[date == "pre-switchover"]), by = "browser"
]

ggsave(plot = ggplot(prominent_percentage, aes(x = reorder(browser, percentage_drop), y = percentage_drop)) +
         geom_bar(stat="identity", fill = "#008080", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous(labels=percent) +
         labs(title = "Switchover decrease in pageviews from top browsers") + coord_flip() +
         geom_hline(mapping = aes(0)) + expand_limits(y = c(-1,1)),
       file = "ua_proportionate.png")

#Search analysis
data <- read.delim("iran_search_data.tsv", as.is = TRUE, header = TRUE)
data <- data[1:(nrow(data)-2),]
data <- data.table(date = as.Date(paste(data$year, data$month, data$day, sep = "-")),
                   domain = gsub(x = data$uri_host, pattern = ".m.", fixed = TRUE, replacement = "."),
                   type = ifelse(as.logical(data$is_https) == TRUE, "https", "http"),
                   searches = data$X_c5)

#By day
by_day <- data[,j=list(searches = sum(searches)), by = c("date","type")]
ggsave(plot = ggplot(by_day, aes(x = date, y = searches, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "HTTP and HTTPS Wikimedia search events from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_searches.png"
)

en_by_day <- data[data$domain == "en.wikipedia.org",j=list(searches = sum(searches)), by = c("date","type")]
ggsave(plot = ggplot(en_by_day, aes(x = date, y = searches, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "en.wikipedia.org search events from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_en_searches.png"
)

fa_by_day <- data[data$domain == "fa.wikipedia.org",j=list(searches = sum(searches)), by = c("date","type")]
ggsave(plot = ggplot(fa_by_day, aes(x = date, y = searches, group = type, type = type, colour = type)) + geom_line(size=2) +
         theme_fivethirtyeight() + scale_x_date(breaks = "week") + scale_y_continuous() +
         labs(title = "fa.wikipedia.org search events from Iranian IP addresses",
              x = "Date",
              y = "Pageviews"),
       file = "iran_fa_searches.png"
)

# User agent analysis
ua_data <- read.delim("iran_search_ua_data.tsv", as.is = TRUE, header = TRUE)
ua_data <- data.table(date = as.Date(paste(ua_data$year, ua_data$month, ua_data$day, sep = "-")),
                      user_agent = ua_data$user_agent,
                      events = ua_data$pageviews)
ua_data <- ua_data[complete.cases(ua_data),]

#Parse the agents and generate the most prominent browsers
agents <- parse_agents(ua_data$user_agent)
browsers <- data.table(date = ua_data$date, browser = paste(agents$browser, agents$browser_major),
                       searches = ua_data$events)
browsers <- browsers[,j=list(searches = sum(searches)), by = c("date","browser")]
browsers <- browsers[order(browsers$searches, decreasing = TRUE),]
prominent_browsers <- browsers$browser[browsers$date == as.Date("2015-06-08")][1:10]
prominent_browsers <- browsers[browsers$browser %in% prominent_browsers,]
prominent_browsers$date <- as.character(prominent_browsers$date)
prominent_browsers$date[prominent_browsers$date == "2015-06-08"] <- "pre-switchover"
prominent_browsers$date[!prominent_browsers$date == "pre-switchover"] <- "post-switchover"

#Graph the change between the two dates
ggsave(plot = ggplot(prominent_browsers, aes(x = reorder(browser, searches), y = searches, fill = factor(date))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Top browsers for Searches from Iranian IP addresses") + coord_flip(),
       file = "ua_search_data.png")
