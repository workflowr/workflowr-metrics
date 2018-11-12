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
# fname <- "data/github-projects.txt"
stopifnot(file.exists(fname))

# https://github.com/search?q=_site.yml+in%3Apath+path%3Aanalysis&type=Code
# Doesn't appear to accept per_page argument. Only returns 30 at a time
projects <- list()
page <- 1
while (TRUE) {
  # Can't pass page argument because of the query I am using. Also, can't use
  # .limit argument because of the structure of the search API results.
  g <- gh(paste0("/search/code?page=", page,
                 "&q=_site.yml+in%3Apath+path%3Aanalysis&sort=indexed&per_page=100"))
  projects <- c(projects, g$items)
  if (length(g$items) < 30 || page > 20) {
    break
  } else {
    page <- page + 1
    # To avoid triggering abuse detection mechanisms
    Sys.sleep(15)
  }
}

stopifnot(length(projects) == g$total_count)

project_users <- Map(function(x) x[["repository"]][["owner"]][["login"]],
                     projects)
project_users <- unlist(project_users)

project_names <- Map(function(x) x[["repository"]][["name"]],
                     projects)
project_names <- unlist(project_names)

# Get created_at dates
created_at <- character(length(project_users))
for (i in seq_along(project_users)) {
  g <- gh("/repos/:owner/:repo", owner = project_users[i],
          repo = project_names[i])
  created_at[i] <- g$created_at
  Sys.sleep(0.25)
}
created_at <- as_date(created_at)

output <- data.frame(date = created_at, user = project_users,
                     repo = project_names, stringsAsFactors = FALSE)
output <- output[order(output$date), ]
# Note: Some repositoires may have been created prior to the beta release of
# workflowr in Dec 2016 because they were later converted to workflowr
# projects.

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
