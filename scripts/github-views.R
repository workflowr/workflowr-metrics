#!/usr/bin/env Rscript

# Get number of views of workflowr GitHub repository
#
# https://help.github.com/articles/about-repository-graphs/#traffic
# https://github.com/jdblischak/workflowr/graphs/traffic
# https://help.github.com/articles/viewing-traffic-to-a-repository/
# https://developer.github.com/v3/repos/traffic/

suppressPackageStartupMessages(library("gh"))
suppressPackageStartupMessages(library("lubridate"))
suppressPackageStartupMessages(library("purrr"))

views <- gh("/repos/:owner/:repo/traffic/views",
            owner = "jdblischak", repo = "workflowr")
views <- views$views
views <- map_dfr(views, function(x) as.data.frame(x, stringsAsFactors = FALSE))
views$timestamp <- as_date(views$timestamp)
colnames(views)[1] <- "date"

write.table(views, file = stdout(), quote = FALSE, sep = "\t",
            row.names = FALSE)
