#!/usr/bin/env Rscript

# Plot average daily downloads of workflowr package.

library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)

downloads <- read_delim("data/cranlogs.txt", delim = "\t")

downloads %>%
  mutate(day = wday(date, label = TRUE)) %>%
  # filter(date > ymd("2019-01-01")) %>%
  group_by(day) %>%
  summarize(avg = mean(count)) %>%
  ggplot(aes(x = day, y = avg)) +
  geom_point() +
  labs(x = "Day of week", y = "Average number of downloads",
       title = "Daily average downloads for workflowr package")
