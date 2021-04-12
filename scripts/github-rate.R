#!/usr/bin/env Rscript

# Get rate limit for GitHub API
#
# Requires environment variable GITHUB_PAT with GitHub token
#
# https://developer.github.com/v3/rate_limit/

suppressPackageStartupMessages(library("gh"))

rate_lim <- gh("/rate_limit")

message(Sys.time())

message("Account: ", gh_whoami()$login)

msg_core <- sprintf("Core: %d / %d",
                    rate_lim$resources$core$remaining,
                    rate_lim$resources$core$limit)
message(msg_core)

msg_search <- sprintf("Search: %d / %d",
                    rate_lim$resources$search$remaining,
                    rate_lim$resources$search$limit)
message(msg_search)
