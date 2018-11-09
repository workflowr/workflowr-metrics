#!/usr/bin/env Rscript

# Obtain number of downloads from RStudio CRAN mirror for last 14 days
#
# https://cranlogs.r-pkg.org/
# https://github.com/metacran/cranlogs

suppressPackageStartupMessages(library("cranlogs"))
suppressPackageStartupMessages(library("lubridate"))

fname <- commandArgs(trailingOnly = TRUE)[1]
# fname <- "data/cranlogs.txt"
stopifnot(file.exists(fname))

datafile <- read.delim(fname, stringsAsFactors = FALSE)
datafile$date <- as_date(datafile$date)

# workflowr was released on 2018-04-23
downloads <- cran_downloads(package = "workflowr",
                            from = today() - 14,
                            to = today())
downloads[["package"]] <- NULL
downloads$date <- as_date(downloads$date)

# Combine
date_min <- min(downloads$date)
output <- rbind(datafile[datafile$date < date_min, ], downloads)

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
