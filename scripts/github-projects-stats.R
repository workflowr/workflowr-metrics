#!/usr/bin/env Rscript

# Clone public workflowr projects on GitHub to measure additional metrics.
#
# Currently this file is only run locally.

suppressPackageStartupMessages(library("git2r"))
suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("workflowr"))

infile <- "data/github-projects.txt"
outfile <- "data/github-projects-stats.txt"
stopifnot(file.exists(infile))

projects <- read.delim(infile, stringsAsFactors = FALSE)

commits_total <- numeric(length(projects))
commits_last <- character(length(projects))
commits_first <- character(length(projects))
commits_authors  <- numeric(length(projects))
commits_publish <- numeric(length(projects))
files_total <- numeric(length(projects))
files_rmd <- numeric(length(projects))

for (i in 1:nrow(projects)) {
  user <- projects$user[i]
  repo <- projects$repo[i]
  url_clone <- sprintf("https://github.com/%s/%s.git", user, repo)
  print(i)
  print(url_clone)
  tmpdir <- file.path(tempdir(), repo)
  r <- clone(url_clone, local_path = tmpdir)

  # Analyze commits
  log <- commits(r)
  commits_total[i] <- length(log)
  commits_last_git <- log[[1]][["author"]][["when"]]
  commits_last[i] <- as.character(as_date(as.character(commits_last_git)))
  commits_first_git <- log[[length(log)]][["author"]][["when"]]
  commits_first[i] <- as.character(as_date(as.character(commits_first_git)))
  authors <- vapply(log, function(x) x[["author"]][["name"]], character(1))
  commits_authors[i] <- length(unique(authors))
  messages <- vapply(log, function(x) x[["message"]], character(1))
  commits_publish[i] <- sum(messages == "Build site.")

  # Analyze files
  files <- list.files(path = tmpdir, full.names = TRUE, recursive = TRUE)
  files_total[i] <- length(files)
  attempt <- try(s <- wflow_status(project = tmpdir), silent = TRUE)
  if (class(attempt) == "try-error") {
    files_rmd[i] <- NA_integer_
  } else {
    files_rmd[i] <- nrow(s$status)
  }

  unlink(tmpdir, recursive = TRUE)
}

output <- data.frame(commits_total, commits_last, commits_first,
                     commits_authors, commits_publish, files_rmd,
                     files_total, stringsAsFactors = FALSE)
output <- cbind(projects, output)

write.table(output, file = outfile, quote = FALSE, sep = "\t", row.names = FALSE)
