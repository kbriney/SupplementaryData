library(tidyverse)
library(stringr)
library(lubridate)
library(httr)
#library(rcrossref)


# Formating DOI data correctly
doi_lookup <- select(dataLinks_doi, related_url_doi)
doi_lookup <- str_extract(doi_lookup$related_url_doi, "10\\.[0123456789]*")
doi_lookup <- as_tibble(doi_lookup[!is.na(doi_lookup)])

# Scrape data from CrossRef
for (i in 1:dim(doi_lookup)[1]) {
  doi <- as.character(slice(doi_lookup,i))
  jsoninput <- paste("https://api.crossref.org/prefixes/", doi, sep="")
  results <- paste(fpath, "/doi-data/crossref/", doi, ".json", sep="")
  try(download.file(jsoninput,results, quiet=TRUE), silent=TRUE)
}

# Scrape data from DataCite
for (i in 1:dim(doi_lookup)[1]) {
  doi <- as.character(slice(doi_lookup,i))
  jsoninput <- paste("https://api.datacite.org/prefixes/", doi, sep="")
  results <- paste(fpath, "/doi-data/datacite/", doi, ".json", sep="")
  try(download.file(jsoninput,results, quiet=TRUE), silent=TRUE)
}

