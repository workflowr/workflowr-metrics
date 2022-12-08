#!/bin/bash
set -eu

# Install dependencies with APT/r2u

apt-get install --yes \
  pandoc \
  r-cran-cranlogs \
  r-cran-gh \
  r-cran-lubridate \
  r-cran-packagerank \
  r-cran-rmarkdown \
  r-cran-r.utils

# List installed R packages
apt list --installed 'r-*'
