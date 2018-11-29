#!/usr/bin/env Rscript

# Get number of watchers of workflowr GitHub repository
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://developer.github.com/v3/activity/watching/#list-watchers

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))

fname <- commandArgs(trailingOnly = TRUE)[1]
# fname <- "data/github-watchers.txt"
stopifnot(file.exists(fname))

watching <- gh("/repos/:owner/:repo/subscribers",
               owner = "jdblischak", repo = "workflowr",
               per_page = 100, .limit = Inf)

watchers <- Map(function(x) x$login, watching)
watchers <- unlist(watchers)
watchers <- sort(watchers)

output <- data.frame(watcher = watchers, stringsAsFactors = FALSE)

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
