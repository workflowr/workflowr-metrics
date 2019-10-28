pkgs <- c(
  "cranlogs",
  "gh",
  "lubridate",
  "packageRank",
  "rmarkdown"
)
# To run scripts/github-projects-stats.R locally
# pkgs <- c(pkgs, "git2r", "workflowr")

installed <- rownames(installed.packages())

for (p in pkgs) {
  if (!p %in% installed) install.packages(p)
}
