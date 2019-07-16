library(dplyr)
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())
library(lubridate)

## Projects --------------------------------------------------------------------

projects <- read.delim("data/github-projects.txt", stringsAsFactors = FALSE)
projects$count <- 1
projects$cumulative <- cumsum(projects$count)
projects$date <- date(projects$date)

proj_cum <- ggplot(projects, aes(x = date, y = cumulative)) +
  geom_point() +
  labs(title = "Cumulative GitHub projects",
       x = "Date", y = "Number of projects") +
  scale_x_date(limits = c(as.Date("2017-01-01"), NA))
proj_cum

proj_mon <- projects %>%
  mutate(year = year(date),
         mon = month(date),
         yearmon = sprintf("%4d-%02d", year, mon),
         yearmon = parse_date_time(yearmon, "y-m"),
         yearmon = date(yearmon)) %>%
  group_by(yearmon) %>%
  summarize(new_proj = n()) %>%
  ggplot(aes(x = yearmon, y = new_proj)) + geom_col() +
  labs(title = "New GitHub projects",
       x = "Month", y = "Number of projects") +
  scale_x_date(limits = c(as.Date("2017-01-01"), NA))
proj_mon

# Stars ------------------------------------------------------------------------

stars <- read.delim("data/github-stars.txt", stringsAsFactors = FALSE)
stars$count <- 1
stars$cumulative <- cumsum(stars$count)
stars$date <- date(stars$date)

stars_cum <- ggplot(stars, aes(x = date, y = cumulative)) +
  geom_point() +
  labs(title = "Cumulative GitHub stars",
       x = "Date", y = "Number of stars") +
  scale_x_date(limits = c(as.Date("2017-01-01"), NA))
stars_cum

stars_mon <- stars %>%
  mutate(year = year(date),
         mon = month(date),
         yearmon = sprintf("%4d-%02d", year, mon),
         yearmon = parse_date_time(yearmon, "y-m"),
         yearmon = date(yearmon)) %>%
  group_by(yearmon) %>%
  summarize(new_proj = n()) %>%
  ggplot(aes(x = yearmon, y = new_proj)) + geom_col() +
  labs(title = "New GitHub stars",
       x = "Month", y = "Number of stars") +
  scale_x_date(limits = c(as.Date("2017-01-01"), NA))
stars_mon

# Final plot -------------------------------------------------------------------

plot_grid(proj_cum, proj_mon, stars_cum, stars_mon)
ggsave("growth.png", width = 10, height = 10)
