#!/bin/bash

Rscript scripts/cranlogs.R > data/cranlogs.txt
Rscript scripts/github-views.R > data/github-views.txt
