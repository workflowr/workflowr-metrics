#!/usr/bin/env Rscript

# Obtain rank of package on previous Wednesday. Based on RStudio CRAN mirror (ie
# cranlogs).
#
# https://github.com/lindbrook/packageRank
#
# Also see scripts/plot-cranlogs.R

suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("packageRank"))

fname <- commandArgs(trailingOnly = TRUE)[1]
# fname <- "data/packagerank.txt"
stopifnot(file.exists(fname))

datafile <- read.delim(fname, stringsAsFactors = FALSE)
datafile$date <- as_date(datafile$date)

last_wed <- floor_date(today(), unit = "week", week_start = 3)
# If the script is run on Wed, use previous Wed
if (last_wed == today()) last_wed <- last_wed - 7
pkgrank <- packageRank(packages = "workflowr", date = last_wed)

newdata <- pkgrank$package.data
output <- rbind(datafile, newdata)

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
