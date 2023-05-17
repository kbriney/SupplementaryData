# SupplementaryData
## Analysis of supplementary data links in CaltechAUTHORS repository

Author: Kristin A. Briney

Date: 2022-01

Dataset downloaded: 2023-05-16 by Tom Morrell, @tmorrell

## Research Questions

1. Where are Caltech authors sharing their research data?
2. What data is no longer available?
   - How does this map over time?
   - Are there specific sites where data is more likely to disappear?
3. Can we outreach to gather the missing data into the CaltechDATA repository?

## Still Need

- ~~Need year data for analysis~~

## Outstanding Research Questions

### Questions that Still Need to be Addressed

- How to handle outreach for missing data?

### Questions Already Answered

- ~~Are there publications with multiple data links?~~
  - Yes, that is calculated in 1-DataParsing.R as dataLinks_perRecord and dataLinks_avg
- ~~I'm assuming one link per description (either URL or DOI) so 
  should not be possible to have both a URL and DOI for one related link record?~~
  - Verified with George on 2022-03-23 that there are no duplicates
  - Either have URL or DOI, DOI preferred
- ~~How thorough is the collection of related links?~~
  - Verified with George on 2022-04-28 that we've been collecting supplemental files and links for about a decade
  - Thoroughness is hard to estimate
- ~~Do I want to clean and analyze related link descriptions?~~
  - Not as part of this project, could be a later effort
- ~~Do I want to rectify URL and DOI domains (e.g. merge CaltechDATA URLs with DOIs), or keep separate?~~
  - Going to keep separate
  
## To-Do List

- ~~Fix regex to match with base URL domain in script 1~~
- ~~Scraping DOI prefixes~~
  - ~~need to handle 404's~~
  - ~~clean and process scraped data~~
  - ~~analyze URL and DOI domains~~
- ~~Identify 404's~~
  - ~~dedupe publications w/ multiple links?~~ (not necessary)
  - ~~count URL's the match base domain~~
  - ~~webscrape~~
  - ~~count 404's~~
- ~~Parse publication date information~~
- Analyze 404's
  - Verify that 404's are actually dead
  - Check file-type URLs by hand
  - Analyze with respect to date
  - ~~Correlate DOI and URL domains?~~
  - Analyze with respect to site
- Outreach
  - Check to see if we already have supplemental data files in CaltechAUTHORS coresponding to dead links
  - Create spreadsheet of articles, links, and contacts


## Resources

- Aydin, O. (2018). *R Web Scraping Quick Start Guide: Techniques and Tools to Crawl and Scrape Data from Websites.* United Kingdom: Packt Publishing.