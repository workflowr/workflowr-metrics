#!/usr/bin/env Rscript

# Get number of stars of workflowr GitHub repository
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://developer.github.com/v3/activity/starring/#list-stargazers

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))

fname <- commandArgs(trailingOnly = TRUE)[1]
# fname <- "data/github-stars.txt"
stopifnot(file.exists(fname))

stars <- list()
# per_page maxed out at 100
page <- 1
while (TRUE) {
  g <- gh("/repos/:owner/:repo/stargazers",
          owner = "jdblischak", repo = "workflowr",
          .send_headers = c(Accept = "application/vnd.github.v3.star+json"),
          per_page = 100, page = page)
  if (length(g) == 1 && g == "") break
  stars <- c(stars, g)
  if (length(g) < 100 || page > 20) break
  page <- page + 1
  Sys.sleep(0.25)
}

starred_at <- Map(function(x) x$starred_at, stars)
starred_at <- unlist(starred_at)
starred_at <- as_date(starred_at)
stargazers <- Map(function(x) x$user$login, stars)
stargazers <- unlist(stargazers)

output <- data.frame(date = starred_at, stargazer = stargazers,
                     stringsAsFactors = FALSE)

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
