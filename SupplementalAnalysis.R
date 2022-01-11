# An analysis of supplementary data links in CaltechAUTHORS
# Kristin A. Briney
# 2022-01

library(tidyverse)
library(stringr)
library(lubridate)


# Relevant file paths, change as necessary
fpath <- getwd()
fname <- "supp-data.csv"


# Read supplementary data file
finput <- paste(fpath, fname, sep="/")
publications <- read_csv(finput)

# Summary counts of types of related links
relatedLinks_type <- count(publications, description)

# Filter out related links containing "Data" or "data" and join them into one tibble
dataLinks_bigD <- filter(publications, str_detect(publications$description, "Data"))
dataLinks_littleD <-  filter(publications, str_detect(publications$description, "data"))
dataLinks <- union(dataLinks_bigD, dataLinks_littleD)

# Summary counts of types of data links
dataLinks_type <- count(dataLinks, description)

