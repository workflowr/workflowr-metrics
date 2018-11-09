#!/usr/bin/env Rscript

# Obtain number of downloads from RStudio CRAN mirror
#
# https://cranlogs.r-pkg.org/
# https://github.com/metacran/cranlogs

library("cranlogs")
library("lubridate")

# workflowr was released on 2018-04-23
downloads <- cran_downloads(package = "workflowr",
                            from = "2018-04-23",
                            to = today())
downloads$cumulative <- cumsum(downloads$count)
downloads[["package"]] <- NULL

write.table(downloads, file = stdout(), quote = FALSE, sep = "\t",
            row.names = FALSE)
