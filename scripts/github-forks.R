#!/usr/bin/env Rscript

# Get number of forks of workflowr GitHub repository
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://developer.github.com/v3/repos/forks/#list-forks

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))

fname <- commandArgs(trailingOnly = TRUE)[1]
# fname <- "data/github-forks.txt"
stopifnot(file.exists(fname))

forks <- gh("/repos/:owner/:repo/forks",
            owner = "jdblischak", repo = "workflowr", sort = "oldest",
            per_page = 100, .limit = Inf)

forked_at <- Map(function(x) x$created_at, forks)
forked_at <- unlist(forked_at)
forked_at <- as_datetime(forked_at)
users <- Map(function(x) x$owner$login, forks)
users <- unlist(users)
updated_at <- Map(function(x) x$updated_at, forks)
updated_at <- unlist(updated_at)
updated_at <- as_datetime(updated_at)

# Confirm it is sorted in chronological order
stopifnot(diff(forked_at) >= 0)

# How much time between original fork and most recent update? Only a few seconds
# difference if no subsequent changes were made. Measured in seconds.
update_difftime <- updated_at - forked_at

output <- data.frame(date = as_date(forked_at), user = users, update_difftime,
                     stringsAsFactors = FALSE)

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
