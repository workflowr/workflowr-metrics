# Data

Explanation of columns of `github-projects-stats` (created by
`scripts/github-projects-stats.txt`):

* `date` - Date the GitHub repository was created
* `user` - GitHub username
* `repo` - GitHub repository name
* `forks` - The number of forks of the repository
* `stars` - The number of stars of the repository
* `open_issues` - Number of Issues currently open (includes Pull Requests)
* `commits_total` - The total number of Git commits
* `commits_last` - The date of the most recent commit
* `commits_first` - The date of the first commit
* `commits_authors` - The total number of unique authors (likely an overestimate
    because users don't always consistently set `user.name` across machines)
* `commits_publish` - The total number of automated commits with the message
    "Build site." (created by `wflow_publish()`)
* `files_total` - The total number of files in the repository (does not include
    hidden files starting with `.`)
* `files_rmd` - The total number of R Markdown files in the analysis directory
    (determined using `wflow_status()`). If this fails (e.g. because workflowr
    project is in subdirectory), the value will be `NA`.
