# How is workflowr used? How long is a typical workflowr project on GitHub
# actively developed?
#
# Main caveat: We know the date the repository was created, but not the date it
# converted to a workflowr project. Some existing projects may have migrated to
# use workflowr.

library("basetheme")
wflowTheme <- basetheme("clean")
wflowTheme[c("col.main", "col.lab", "col.sub")] <- "#6E2E9E"
basetheme(wflowTheme)
library("data.table")

projects <- fread("data/github-projects.txt")
str(projects)
toDate <- function(x) as.Date(x, format = "%Y-%m-%d", tz = "America/Chicago")
projects[, date := toDate(date)]
projects[, last_update := toDate(last_update)]
projects[, last_push := toDate(last_push)]
projects[, rangeUpdate := last_update - date]
projects[, rangePush := last_push - date]
projects[, rangeLag := last_update - last_push]

str(projects)
sum(is.na(projects$last_push))
projects[is.na(last_push), date]

difftimeSummary <- function(x, units = "days") summary(as.double(x, units = units))
difftimeSummary(projects$rangeUpdate)
difftimeSummary(projects$rangePush)
difftimeSummary(projects$rangeLag)

# OK. So for the majority of projects, the last update is the same date as the
# last push.
mean(projects$rangeLag == 0, na.rm = TRUE)

# Remove missing values
projects <- projects[!is.na(last_push), ]

projectsUsed <- projects[rangeUpdate > 3 & rangePush > 3, ]
nrow(projectsUsed)

png("figures/projects-duration.png", width = 7, height = 7, units = "in", res = 72 * 2)
hist(as.double(projectsUsed$rangeUpdate, units = "days"),
     col = "#6E2E9E",
     xlab = "Days between creation and last update",
     ylab = "Number of projects",
     main = sprintf("Distribution of project duration"),
     sub = sprintf("Only includes projects used more than 3 days (total of %d)",
                   nrow(projectsUsed)))
dev.off()

users <- projects[,
                  .(repos = .N,
                    start = min(date),
                    end = max(last_push),
                    rangeRepoMean = mean(rangePush),
                    rangeRepoMedian = median(rangePush)
                  ),
                  by = user]
users[, rangeUser := end - start]
setorder(users, -repos)
users

summary(users)
hist(users$repos)
hist(as.double(users$rangeUser, units = "days"))
hist(as.double(users$rangeRepoMean, units = "days"))
hist(as.double(users$rangeRepoMedian, units = "days"))

plot(users$repos, users$rangeUser)
plot(users$repos, users$rangeRepoMean)
plot(users$repos, users$rangeRepoMedian)
rug(users$rangeRepoMedian, side = 4)

plotUsagePatterns <- function(totalRepos, averageUsageDuration, labels = NULL) {
  plot.new()
  plot.window(xlim = extendrange(totalRepos, f = c(0, 0.1)),
              ylim = range(averageUsageDuration))
  grid()
  points(totalRepos, averageUsageDuration)

  axis(1, lwd = 1, font.axis=2, pos = 0)
  axis(2, lwd = 1, font.axis=2, pos = 0)

  title(xlab = "Number of projects per user")
  title(ylab = "Average length of project duration (days)")
  title(main = sprintf("User usage patterns (%d users)", length(totalRepos)), adj = 0)

  if (!is.null(labels)) {
    powerUsers <- totalRepos > quantile(totalRepos, 0.99) |
                  averageUsageDuration > quantile(averageUsageDuration, 0.99)
    labelsToPlot <- ifelse(powerUsers, labels, "")
    text(totalRepos, averageUsageDuration, labels = labelsToPlot,
         pos = 4, cex = 0.75)
  }
}

png("figures/users-all.png", width = 7, height = 7, units = "in", res = 72 * 2)
plotUsagePatterns(users$repos, users$rangeRepoMean, labels = users$user)
title(sub = sprintf("Data last collected on %s", max(projects$last_update)))
dev.off()

usersLongTerm <- users[rangeRepoMean > 50, ]
nrow(usersLongTerm)
png("figures/users-power.png", width = 7, height = 7, units = "in", res = 72 * 2)
plotUsagePatterns(usersLongTerm$repos, usersLongTerm$rangeRepoMean, labels = usersLongTerm$user)
title(sub = sprintf("Data last collected on %s", max(projects$last_update)))
dev.off()
