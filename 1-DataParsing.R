# An analysis of supplementary data links in CaltechAUTHORS
# Kristin A. Briney
# 2022-01

library(tidyverse)
library(stringr)
library(lubridate)
library(httr)


# Relevant file paths, change as necessary
fpath <- getwd()
fname <- "supp-data.csv"


# Read supplementary data file
finput <- paste(fpath, fname, sep="/")
publications <- read_csv(finput)

# Summary counts of types of related links
relatedLinks_type <- count(publications, description)

# Filter out related links containing "Data" or "data" and join them into one tibble
dataLinks_bigD <- filter(publications, str_detect(description, "Data"))
dataLinks_littleD <-  filter(publications, str_detect(description, "data"))
dataLinks <- union(dataLinks_bigD, dataLinks_littleD)

# Summary counts of types of data links
dataLinks_type <- count(dataLinks, description)

# Add column for URL and DOI domain
dataLinks <- mutate(dataLinks, related_url_short = str_extract(related_url, "https?://[^/]*"))
dataLinks <- mutate(dataLinks, related_url_doi = str_extract(related_url, "10\\.[0123456789]*"))

# Summary counts for data links by URL and DOI domain
dataLinks_url <- count(dataLinks, related_url_short) %>% arrange(desc(n))
dataLinks_doi <- count(dataLinks, related_url_doi) %>% arrange(desc(n))

# Parse dates into year
dataLinks <- mutate(dataLinks, year = str_sub(dataLinks$date, 1,4))
publications <- mutate(publications, year = str_sub(publications$date, 1,4))

# Count number of links per year
dataLinks_year <- count(dataLinks, year) %>% arrange(desc(year))
links_year <- count(publications, year) %>% arrange(desc(year))

# Count number of links per record
dataLinks_perRecord <- count(dataLinks, eprint_id) %>% arrange(desc(n))
dataLinks_avg <- summarise(dataLinks_perRecord, avg=mean(n))

# Write out summary count data
foutput_url <- paste(fpath, "supp-data_URLs.csv", sep="/")
write_csv(dataLinks_url, foutput_url)

foutput_doi <- paste(fpath, "supp-data_DOIs.csv", sep="/")
write_csv(dataLinks_doi, foutput_doi)

foutput_allYears <- paste(fpath, "years_all.csv", sep="/")
write_csv(links_year, foutput_allYears)

foutput_dataYears <- paste(fpath, "years_data.csv", sep="/")
write_csv(dataLinks_year, foutput_dataYears)