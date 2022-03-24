library(tidyverse)

# Relevant file paths, change as necessary
fpath <- getwd()
fname <- "doi-owners.csv"

# Read doi data file
# Specifically wrote out and read in file again to be able to add information about
#   DOI prefixes that are not in CrossRef or DataCite into the CSV file in between processing.
finput <- paste(fpath, fname, sep="/")
doi_own <- read_csv(finput, col_types=cols(doi=col_character(), doi_name=col_character()))


# Add DOI name information to larger dataLinks data
doi_own <- rename(doi_own, related_url_doi = doi)
dataLinks <- left_join(dataLinks, doi_own, by = "related_url_doi")
