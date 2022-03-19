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

## Outstanding Issues

- Are there publications with multiple data links?
- I'm assuming one link per description (either URL or DOI) so 
  should not be possible to have both a URL and DOI for one related link record?
- Do I want to clean and analyze related link descriptions?
- How to handle outreach for missing data?

## Code Still to Write

- Scraping DOI prefixes
  - ~~need to handle 404's~~
  - clean and process scraped data
- Measure decay of URLs and DOIs by counting 404's
  - dedupe publications w/ multiple links?
  - how to handle content that's moved?
- Analyze with respect to date
- Analyze with respect to site
