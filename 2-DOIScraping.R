# An analysis of supplementary data links in CaltechAUTHORS, stage 2:
#   Scraping and processing DOI prefixes
# Kristin A. Briney
# 2022-03

library(tidyverse)
library(stringr)
library(lubridate)
library(httr)
library(rjson)


# Relevant file paths, change as necessary
fpath <- getwd()

# Read supplementary data file
finput <- paste(fpath, "1-supp-data_DOIs.csv", sep="/")
dataLinks_doi <- read_csv(finput, col_types=cols(related_url_doi=col_character()))

# Formating DOI list correctly
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

# Parse crossref names from JSON data
doi_files <- Sys.glob("doi-data/crossref/*.json")
doi_files <- as_tibble(doi_files)

crossref <- tibble()

for (i in 1:dim(doi_files)[1]) {
  doi <- str_extract(doi_files[i,1], "10\\.[0123456789]*")
  doi_json <- fromJSON(file = as.character(doi_files[i,1]))
  doi_name <- doi_json$message$name
  doi_crossref <- tibble("doi" = doi, "doi_name" = doi_name)
  crossref <- bind_rows(crossref, doi_crossref)
}


# Scrape data from DataCite
for (i in 1:dim(doi_lookup)[1]) {
  doi <- as.character(slice(doi_lookup,i))
  jsoninput <- paste("https://api.datacite.org/prefixes/", doi, sep="")
  results <- paste(fpath, "/doi-data/datacite/", doi, ".json", sep="")
  try(download.file(jsoninput,results, quiet=TRUE), silent=TRUE)
}

doi_files <- Sys.glob("doi-data/datacite/*.json")
doi_files <- as_tibble(doi_files)

datacite <- tibble()

for (i in 1:dim(doi_files)[1]) {
  doi <- str_extract(doi_files[i,1], "10\\.[0123456789]*")
  doi_json <- fromJSON(file = as.character(doi_files[i,1]))
  
  # less specific owner information, always available
  doi_name <- doi_json$data$relationships$providers$data[[1]]$id
  # more specific owner information, may not always be available
  try({doi_name <- doi_json$data$relationships$clients$data[[1]]$id}, silent=TRUE)
  
  doi_crossref <- tibble("doi" = doi, "doi_name" = doi_name)
  datacite <- bind_rows(datacite, doi_crossref)
}

# Join doi information into one big list
doi_dupes <- intersect(crossref$doi, datacite$doi)
datacite_deduped <- filter(datacite, doi != doi_dupes)
doi_owners <- bind_rows(crossref, datacite_deduped) %>% arrange(doi_name)

# Identify DOIs not found in CrossRef and DataCite
doi_lookup <- rename(doi_lookup, doi = value)
doi_noOwners <- as_tibble(setdiff(doi_lookup$doi, doi_owners$doi))
doi_noOwners <- rename(doi_noOwners, doi = value)
doi_noOwners <- mutate(doi_noOwners, doi_name = "unknown")

# Combine all information into one large tibble
doi_owners <- bind_rows(doi_owners, doi_noOwners)

# Write owner information to file
fpath <- getwd()
foutput_doi <- paste(fpath, "2-doi-owners.csv", sep="/")
write_csv(doi_owners, foutput_doi)
