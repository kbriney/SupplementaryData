library(tidyverse)
library(stringr)
library(lubridate)
library(httr)
#library(rcrossref)


fpath <- getwd()
fname <- "crossref-doi.txt"
foutput <- paste(fpath, fname, sep="/")

doi_lookup <- select(dataLinks_doi, related_url_doi)
doi_lookup <- str_extract(doi_lookup$related_url_doi, "10\\.[0123456789]*")
doi_lookup <- as_tibble(doi_lookup[!is.na(doi_lookup)])

for (i in 1:dim(doi_lookup)[1]) {
  #crossrefPrefixs <- as.data.frame(cr_prefixes_(doi_lookup[i,1]))
  #write(crossrefPrefixs, foutput, append=TRUE)
  
  doi <- as.character(slice(doi_lookup,i))
  jsoninput <- paste("https://api.crossref.org/prefixes/", doi, sep="")
  results <- paste(fpath, "/doi-data/", doi, ".json", sep="")
  download.file(jsoninput,results, quiet=TRUE)
}

# 10.1093