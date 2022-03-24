# SupplementaryData
## Analysis of supplementary data links in CaltechAUTHORS repository

Author: Kristin A. Briney

Date: 2022-01

Dataset downloaded: 2022-01-06 by Tom Morrell, @tmorrell

## Research Questions

1. Where are Caltech authors sharing their research data?
2. What data is no longer available?
   - How does this map over time?
   - Are there specific sites where data is more likely to disappear?
3. Can we outreach to gather the missing data into the CaltechDATA repository?

## Still Need

- Need year data for analysis

## Outstanding Questions

- Are there publications with multiple data links?
  - Yes, that is calculated in 1-DataParsing.R as dataLinks_perRecord and dataLinks_avg
- I'm assuming one link per description (either URL or DOI) so 
  should not be possible to have both a URL and DOI for one related link record?
  - Verified with George on 2022-03-23 that there are no duplicates
  - Either have URL or DOI, DOI preferred
- Do I want to clean and analyze related link descriptions?
- Do I want to rectify URL and DOI domains (e.g. merge CaltechDATA URLs with DOIs), or keep separate?
- How to handle outreach for missing data?

## Code Still to Write

- Scraping DOI prefixes
  - ~~need to handle 404's~~
  - ~~clean and process scraped data~~
  - ~~analyze URL and DOI domains~~
- Measure decay of URLs and DOIs by counting 404's
  - ~~dedupe publications w/ multiple links?~~ (not necessary)
  - how to handle content that's moved?
- Analyze with respect to date
- Analyze with respect to site

## Resources

- Aydin, O. (2018). *R Web Scraping Quick Start Guide: Techniques and Tools to Crawl and Scrape Data from Websites.* United Kingdom: Packt Publishing.