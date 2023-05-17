# An analysis of DOI domains from related data links in CaltechAUTHORS
# Kristin A. Briney
# 2022-03

library(tidyverse)

# Relevant file paths, change as necessary
fpath <- getwd()
fname <- "2-doi-owners.csv"

# Read doi data file
# Specifically wrote out and read in file again to be able to add information about
#   DOI prefixes that are not in CrossRef or DataCite into the CSV file in between processing.
finput <- paste(fpath, fname, sep="/")
doi_own <- read_csv(finput, col_types=cols(doi=col_character(), doi_name=col_character()))

# Add DOI name information to larger dataLinks data
doi_own <- rename(doi_own, related_url_doi = doi)
dataLinks <- left_join(dataLinks, doi_own, by = "related_url_doi")



# CatechDATA URLs to convert
#URL_CaltechDATA <- "https://data.caltech.edu/"
#dataLinks_CaltechURLs <- filter(dataLinks, related_url_short == URL_CaltechDATA) %>%
#  select(eprint_id, record_doi, related_url, description, type)
#
#foutput <- paste(fpath, "3-CaltechDATA_URLs.csv", sep="/")
#write_csv(dataLinks_CaltechURLs, foutput)



# Add names to counts of DOI domains
dataLinks_doi_name <- count(dataLinks, doi_name) %>% arrange(desc(n))

foutput <- paste(fpath, "3-supp-data_DOIs.csv", sep="/")
write_csv(dataLinks_doi_name, foutput)


