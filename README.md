# SupplementaryData
## Analysis of supplementary data links in CaltechAUTHORS repository

Author: Kristin A. Briney

Date: 2022-01

Latest dataset downloaded: 2023-05-16 by Tom Morrell, @tmorrell

## Research Questions

1. Where are Caltech authors sharing their research data?
2. What data is no longer available?
   - How does this map over time?
   - Are there specific sites where data is more likely to disappear?
3. Can we outreach to gather the missing data into the CaltechDATA repository?

## Code Organization

1. 1-DataParsing.R: Cleans up the input data "supp-data.csv" for processing and calculates some summary statistics.
2. 2-DOIScraping.R: Scrapes and processes DOI prefixes
3. 3-DOIAnalysis.R: Adds DOI prefix information back into larger dataset.
4. 4-LinkDecay.R: Scrapes URLs and DOIs to see if the data is still available and outputs data as "4-linkDecay.csv".

Other files are labelled 1-4 at the beginning of the file name to note which part of the analysis workflow they correspond to.

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
- ~~Analyze 404's~~
  - ~~Verify that 404's are actually dead~~
  - ~~Check file-type URLs by hand~~
  - ~~Analyze with respect to date~~
  - ~~Analyze with respect to site~~
- Outreach
  - Check to see if we already have supplemental data files in CaltechAUTHORS coresponding to dead links
  - Create spreadsheet of articles, links, and contacts

## Issues that have been Resolved

- Are there publications with multiple data links?
  - Yes, that is calculated in 1-DataParsing.R as dataLinks_perRecord and dataLinks_avg
- I'm assuming one link per description (either URL or DOI) so 
  should not be possible to have both a URL and DOI for one related link record?
  - Verified with George on 2022-03-23 that there are no duplicates
  - Either have URL or DOI, DOI preferred
- How thorough is the collection of related links?
  - Verified with George on 2022-04-28 that we've been collecting supplemental files and links for about a decade
  - Thoroughness is hard to estimate
- Do I want to clean and analyze related link descriptions?
  - Not as part of this project, could be a later effort
- Do I want to rectify URL and DOI domains (e.g. merge CaltechDATA URLs with DOIs), or keep separate?
  - Going to keep separate

## Resources

- Aydin, O. (2018). *R Web Scraping Quick Start Guide: Techniques and Tools to Crawl and Scrape Data from Websites.* United Kingdom: Packt Publishing.