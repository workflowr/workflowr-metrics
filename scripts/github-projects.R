#!/usr/bin/env Rscript

# Get number of public workflowr projects on GitHub
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://developer.github.com/v3/search/#search-code
# https://developer.github.com/v3/#pagination

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))

fname <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(fname)) fname <- "data/github-projects.txt"
stopifnot(file.exists(fname))

# Wait until sufficient API resources
while (TRUE) {
  source("scripts/github-rate.R")
  if (rate_lim$resources$search$remaining > 10 &&
      rate_lim$resources$core$remaining > 100) {
    break
  }
}

# Search query:
# https://github.com/search?q=_site.yml+in%3Apath+path%3Aanalysis&type=Code
projects <- list()

# The pagination for the search queries is a real pain. The max I can get it to
# return is 100, and I often get duplicated and missing results because of minor
# reorderings around the page boundaries.
total <- gh("/search/code?q=_site.yml+in%3Apath+path%3Aanalysis")$total_count
per_page <- 100
pages <- ceiling(total / per_page)
p <- 1
while (length(projects) < total) {

  g <- gh(paste0("/search/code?page=", p,
                 "&q=_site.yml+in%3Apath+path%3Aanalysis&sort=indexed&per_page=100"))
  projects <- c(projects, g$items)

  # Remove duplicates
  id <- vapply(projects, function(x) x[["repository"]][["id"]], numeric(1))
  projects <- projects[!duplicated(id)]

  p <- if (p < pages) p + 1 else 1
  # To avoid triggering abuse detection mechanisms
  rate_lim <- gh("/rate_limit")
  if (rate_lim$resources$search$remaining < 10) Sys.sleep(15) else Sys.sleep(5)
}

stopifnot(g$total_count == total)
stopifnot(length(projects) == total)

project_users <- vapply(projects,
                        function(x) x[["repository"]][["owner"]][["login"]],
                        character(1))

project_names <- vapply(projects,
                        function(x) x[["repository"]][["name"]],
                        character(1))

# Get created_at dates and other repo info
created_at <- character(length(project_users))
forks <- numeric(length(project_users))
stars <- numeric(length(project_users))
open_issues <- forks <- numeric(length(project_users))
for (i in seq_along(project_users)) {
  g <- gh("/repos/:owner/:repo", owner = project_users[i],
          repo = project_names[i])
  created_at[i] <- g$created_at
  forks[i] <- g$forks_count
  stars[i] <- g$stargazers_count
  open_issues[i] <- g$open_issues_count
  # To avoid triggering abuse detection mechanisms
  rate_lim <- gh("/rate_limit")
  if (rate_lim$resources$core$remaining < 100) Sys.sleep(15) else Sys.sleep(0.5)
}
created_at <- as_date(created_at)

output <- data.frame(date = created_at, user = project_users,
                     repo = project_names, forks, stars, open_issues,
                     stringsAsFactors = FALSE)
output <- output[order(output$date, output$user, output$repo), ]
# Note: Some repositories may have been created prior to the beta release of
# workflowr in Dec 2016 because they were later converted to workflowr
# projects.

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
