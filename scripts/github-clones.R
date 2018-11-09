#!/usr/bin/env Rscript

# Get number of clones of workflowr GitHub repository for last 14 days
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://developer.github.com/v3/repos/traffic/#clones

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))

fname <- commandArgs(trailingOnly = TRUE)[1]
# fname <- "data/github-clones.txt"
stopifnot(file.exists(fname))

datafile <- read.delim(fname, stringsAsFactors = FALSE)
datafile$date <- as_date(datafile$date)

clones <- gh("/repos/:owner/:repo/traffic/clones",
            owner = "jdblischak", repo = "workflowr")
clones <- clones$clones
clones <- do.call(rbind.data.frame, clones)
clones$timestamp <- as_date(clones$timestamp)
colnames(clones)[1] <- "date"

# Combine
date_min <- min(clones$date)
output <- rbind(datafile[datafile$date < date_min, ], clones)

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
