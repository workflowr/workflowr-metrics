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

# Search queries:
#
# Find projects created with workflowr >= 1.0:
# https://github.com/search?q=filename%3A_workflowr.yml
# They contain the file _workflowr.yml
#
# Find projects created with workflowr < 1.0
# https://github.com/search?q=chunks.R+in%3Apath+path%3Aanalysis
# They contain the file analysis/chunks.R
projects <- list()

search_code <- function(query, per_page = 100) {
  results <- list()
  total <- gh(paste0("/search/code?q=", query))$total_count
  pages <- ceiling(total / per_page)

  message(sprintf("Expecting %d search results", total))
  for (p in seq_len(pages)) {
    api_call <- paste0("/search/code?page=", p, "&q=", query,
                       "&per_page=", per_page)
    g <- gh(api_call)
    results <- c(results, g$items)
    Sys.sleep(1)
  }

  message(sprintf("Retreived %d search results", length(results)))
  message(sprintf("The latest count returned by the search was %d", g$total_count))
  stopifnot(length(results) == total || length(results) == g$total_count)
  if (g$total_count != total) {
    warning("Mismatch between original and final estimates of total results: ",
            sprintf("%d vs %d", total, g$total_count))
  }
  return(results)
}

remove_duplicate_projects <- function(projects) {
  id <- vapply(projects, function(x) x[["repository"]][["id"]], numeric(1))
  projects <- projects[!duplicated(id)]
  return(projects)
}

# Search for workflowr 1.0+ projects with a _workflowr.yml file
message("Searching for workflowr 1.0+ projects")
projects <- search_code("filename%3A_workflowr.yml")
message("Finished searching for workflowr 1.0+ projects")
projects <- remove_duplicate_projects(projects)
message(sprintf("Found %d unique workflowr 1.0+ projects", length(projects)))

Sys.sleep(15)

# Search for workflowr <1.0 projects with an analysis/chunks.R file
message("Searching for workflowr <1.0 projects")
projects_beta <- search_code("chunks.R+in%3Apath+path%3Aanalysis")
message("Finished searching for workflowr <1.0 projects")
projects_beta <- remove_duplicate_projects(projects_beta)
message(sprintf("Found %d unique workflowr <1.0 projects", length(projects_beta)))

projects <- c(projects, projects_beta)
projects <- remove_duplicate_projects(projects)

project_users <- vapply(projects,
                        function(x) x[["repository"]][["owner"]][["login"]],
                        character(1))

project_names <- vapply(projects,
                        function(x) x[["repository"]][["name"]],
                        character(1))

# Manually add some known workflowr projects that don't contain a
# _workflowr.yml file (it's not actually required)
project_users <- c(project_users,
                   "stephens999", "brimittleman")
project_names <- c(project_names,
                   "fiveMinuteStats", "apaQTL")

# Get created_at dates and other repo info
created_at <- character(length(project_users))
forks <- numeric(length(project_users))
stars <- numeric(length(project_users))
open_issues <- forks <- numeric(length(project_users))
message("Gathering information for workflowr projects")
for (i in seq_along(project_users)) {
  g <- gh("/repos/:owner/:repo", owner = project_users[i],
          repo = project_names[i])
  created_at[i] <- g$created_at
  forks[i] <- g$forks_count
  stars[i] <- g$stargazers_count
  open_issues[i] <- g$open_issues_count
  # To avoid triggering abuse detection mechanisms
  rate_lim <- gh("/rate_limit")
  if (rate_lim$resources$core$remaining < 100) Sys.sleep(15) else Sys.sleep(1)
  if (i %% 25 == 0) message(sprintf("Completed %d / %d", i, length(project_users)))
}
created_at <- as_date(created_at)

output <- data.frame(date = created_at, user = project_users,
                     repo = project_names, forks, stars, open_issues,
                     stringsAsFactors = FALSE)
output <- output[order(output$date, output$user, output$repo), ]
# Note: Some repositories may have been created prior to the beta release of
# workflowr in Dec 2016 because they were later converted to workflowr
# projects.

# Remove main workflowr repository and the cran mirror
pkgs <- output$repo == "workflowr" & (output$user == "jdblischak" | output$user == "cran")
stopifnot(sum(pkgs) == 2)
output <- output[!pkgs, ]

write.table(output, file = fname, quote = FALSE, sep = "\t", row.names = FALSE)
