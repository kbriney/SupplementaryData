# An analysis of link stability of related data links in CaltechAUTHORS
# Kristin A. Briney
# 2022-03

library(rvest)

# start with new tibble for testing links
linkDecay <- dataLinks

# Break URLs and DOI's into separate columns
linkDecay <- mutate(linkDecay, test_URL = str_extract(related_url, "https?://.*"))
linkDecay <- mutate(linkDecay, test_DOI = str_extract(related_url, "10\\.[0123456789]*/.*"))

# Break URLs and DOI's into separate Tibbles
#   Note that some URLs contain DOI information, so sorting is done by presence
#   of URL and not by presence of DOI
linkDecay_URLs <- filter(linkDecay, !is.na(test_URL))
linkDecay_DOIs <- filter(linkDecay, is.na(test_URL))

# Remove DOI column, rename URL variable, and assign link type
linkDecay_URLs <- select(linkDecay_URLs, -test_DOI)
linkDecay_URLs <- rename(linkDecay_URLs, testLink = test_URL)
linkDecay_URLs <- mutate(linkDecay_URLs, linkType="URL")

# Reformat DOI to include "https://doi.org/", remove extra columns, assign link type
doiRoot <- "https://doi.org/"
linkDecay_DOIs <- mutate(linkDecay_DOIs, testLink = paste(doiRoot, test_DOI, sep=""))
linkDecay_DOIs <- select(linkDecay_DOIs, -test_DOI, -test_URL)
linkDecay_DOIs <- mutate(linkDecay_DOIs, linkType="DOI")

# Combine tibbles back into one larger dataset
linkDecay <- bind_rows(linkDecay_URLs, linkDecay_DOIs)

# Add row number for easier merging of scraped data later
linkDecay <- mutate(linkDecay, rowNum = seq.int(nrow(linkDecay)))



# Testing webscraping
scrapedHeader <- tibble()

for (i in 11:20) {
  print(linkDecay$eprint_id[i])
  html_doc <- NA
  try(html_doc <- read_html(linkDecay$testLink[i]), silent=TRUE)
  if(is.na(html_doc)) header <- "404"
  else
    header <- html_doc %>% html_nodes("title") %>% html_text()
  linkInfo <- tibble("rowNum" = linkDecay$rowNum[i], "linkTitle" = header)
  scrapedHeader <- bind_rows(scrapedHeader, linkInfo)
}
