# An analysis of supplementary data links in CaltechAUTHORS, stage 4:
#   Scraping URLs and DOIs to see if the data is still available.
# Kristin A. Briney
# 2022-03

library(rvest)

fpath <- getwd()

# start with new tibble for testing links
linkDecay <- dataLinks



# Copy URLs and DOI's into separate columns
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

# Write URLs to file for checking for type exclusions
#URLsToCheck <- select(linkDecay_URLs, testLink)
#foutput <- paste(fpath, "URLsToCheck.csv", sep="/")
#write_csv(URLsToCheck, foutput)



## Mark URLs based on spaces and file extensions

# Identify spaces in URLs
URLspaces <- filter(linkDecay_URLs, str_detect(testLink, " "))
linkDecay_URLs <- setdiff(linkDecay_URLs, URLspaces)
URLspaces$linkType <- "ERR"
linkDecay_URLs <- bind_rows(linkDecay_URLs, URLspaces)

# Make exceptions for non-webpage URLs
img <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.img"))
linkDecay_URLs <- setdiff(linkDecay_URLs, img)
img$linkType <- "IMG"
linkDecay_URLs <- bind_rows(linkDecay_URLs, img)

txt <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.txt"))
linkDecay_URLs <- setdiff(linkDecay_URLs, txt)
txt$linkType <- "TXT"
linkDecay_URLs <- bind_rows(linkDecay_URLs, txt)

docx <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.docx"))
linkDecay_URLs <- setdiff(linkDecay_URLs, docx)
docx$linkType <- "DOCX"
linkDecay_URLs <- bind_rows(linkDecay_URLs, docx)

doc <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.doc"))
linkDecay_URLs <- setdiff(linkDecay_URLs, doc)
doc$linkType <- "DOC"
linkDecay_URLs <- bind_rows(linkDecay_URLs, doc)

xlsx <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.xlsx"))
linkDecay_URLs <- setdiff(linkDecay_URLs, xlsx)
xlsx$linkType <- "XLSX"
linkDecay_URLs <- bind_rows(linkDecay_URLs, xlsx)

pdf <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.pdf"))
linkDecay_URLs <- setdiff(linkDecay_URLs, pdf)
pdf$linkType <- "PDF"
linkDecay_URLs <- bind_rows(linkDecay_URLs, pdf)

zip <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.zip"))
linkDecay_URLs <- setdiff(linkDecay_URLs, zip)
zip$linkType <- "ZIP"
linkDecay_URLs <- bind_rows(linkDecay_URLs, zip)

zipR <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.zipR"))
linkDecay_URLs <- setdiff(linkDecay_URLs, zipR)
zipR$linkType <- "ZIPR"
linkDecay_URLs <- bind_rows(linkDecay_URLs, zipR)

gz <- filter(linkDecay_URLs, str_detect(testLink, ".*\\.gz"))
linkDecay_URLs <- setdiff(linkDecay_URLs, gz)
gz$linkType <- "GZ"
linkDecay_URLs <- bind_rows(linkDecay_URLs, gz)


# Check if URL link is equivalent to base URL
linkDecay_URLs <- mutate(linkDecay_URLs, baseURL = str_length(linkDecay_URLs$related_url_short))
linkDecay_URLs <- mutate(linkDecay_URLs, testURL = str_length(linkDecay_URLs$testLink))
linkDecay_URLs <- mutate(linkDecay_URLs, diffURL = (testURL-baseURL))
linkDecay_URLs <- mutate(linkDecay_URLs, linkIsBase = FALSE)
linkDecay_URLs_1 <- filter(linkDecay_URLs, ((diffURL ==1) | (diffURL == 0)))
linkDecay_URLs_2 <- setdiff(linkDecay_URLs, linkDecay_URLs_1)
linkDecay_URLs_1 <- mutate(linkDecay_URLs_1, linkIsBase = TRUE)
linkDecay_URLs <- bind_rows(linkDecay_URLs_1, linkDecay_URLs_2)
# View links to ensure this string comparison logic is correct
#linkCheck <- select(linkDecay_URLs_1, related_url_short, testLink)
linkDecay_URLs <- select(linkDecay_URLs, -baseURL, -testURL, -diffURL)




# Reformat DOI to include "https://doi.org/", remove extra columns, assign link type and add linkIsBase variable
doiRoot <- "https://doi.org/"
linkDecay_DOIs <- mutate(linkDecay_DOIs, testLink = paste(doiRoot, test_DOI, sep=""))
linkDecay_DOIs <- select(linkDecay_DOIs, -test_DOI, -test_URL)
linkDecay_DOIs <- mutate(linkDecay_DOIs, linkType="DOI")
linkDecay_DOIs <- mutate(linkDecay_DOIs, linkIsBase=NA)

# Combine tibbles back into one larger dataset
linkDecay <- bind_rows(linkDecay_URLs, linkDecay_DOIs)


# Add row number for easier merging of scraped data
linkDecay <- mutate(linkDecay, rowNum = seq.int(nrow(linkDecay)))







# Webscraping
scrapedHeader <- tibble()
i<-1



for (i in 1:dim(linkDecay)[1]) {
  # Test variable in case loop gets stuck
  mySpot <- linkDecay$rowNum[i]
  print(mySpot)
  
  # Reset html information each time through the loop
  html_doc <- NA
  
  if(linkDecay$linkType[i] == ("URL") | linkDecay$linkType[i] == ("DOI")) {
    # Try scraping link
    try(html_doc <- read_html(linkDecay$testLink[i]), silent=TRUE)
  
    # If scraping didn't work, write title as 404. Otherwise, extract title from webpage.
    if(is.na(html_doc)) header <- "404"
    else {
      header <- html_doc %>% html_nodes("title") %>% html_text()
      # extract first title as there are sometimes multiple titles
      header <- header[1]
    }
  } else header <- linkDecay$linkType[i]
  
  # Collect row number and title then add to scrapedHeader variable
  linkInfo <- tibble("rowNum" = linkDecay$rowNum[i], "linkTitle" = header)
  scrapedHeader <- bind_rows(scrapedHeader, linkInfo)
}

# Write out html title information to CSV
foutput <- paste(fpath, "4-linkTitles.csv", sep="/")
write_csv(scrapedHeader, foutput)

linkDecay <- left_join(linkDecay, scrapedHeader, by = "rowNum")

# Identify 404's
linkDecay_404 <- filter(linkDecay, linkTitle == 404)
foutput <- paste(fpath, "4-link404s.csv", sep="/")
write_csv(linkDecay_404, foutput)

# Write out all data
foutput <- paste(fpath, "4-linkDecay.csv", sep="/")
write_csv(linkDecay, foutput)
