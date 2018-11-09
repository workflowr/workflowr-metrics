#!/usr/bin/env Rscript

# Get number of views of workflowr GitHub repository
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://help.github.com/articles/about-repository-graphs/#traffic
# https://github.com/jdblischak/workflowr/graphs/traffic
# https://help.github.com/articles/viewing-traffic-to-a-repository/
# https://developer.github.com/v3/repos/traffic/

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("purrr"))

fname <- commandArgs(trailingOnly = TRUE)[1]
stopifnot(file.exists(fname))

datafile <- read.delim(fname, stringsAsFactors = FALSE)
datafile$date <- as_date(datafile$date)

views <- gh("/repos/:owner/:repo/traffic/views",
            owner = "jdblischak", repo = "workflowr")
views <- views$views
views <- map_dfr(views, function(x) as.data.frame(x, stringsAsFactors = FALSE))
views$timestamp <- as_date(views$timestamp)
colnames(views)[1] <- "date"

# Combine
date_min <- min(views$date)
output <- rbind(datafile[datafile$date < date_min, ], views)

write.table(output, file = fname, quote = FALSE, sep = "\t",
            row.names = FALSE)
