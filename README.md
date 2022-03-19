# SupplementaryData
Analysis of supplementary data links in CaltechAUTHORS repository

Author: Kristin A. Briney
Date: 2022-01


Dataset downloaded: 2022-01-06

Needs:
- Need year data for analysis

Outstanding questions:
- Are there publications with multiple data links?
- I'm assuming one link per description (either URL or DOI) so 
  should not be possible to have both a URL and DOI for one related link record?
- Do I want to clean and analyze related link descriptions?
- How to handle outreach for missing data?

Code to write:
- Scraping DOI prefixes
  - need to handle 404's
- Measure decay of URLs and DOIs by counting 404's
  - how to handle content that's moved?
- Analyze with respect to date
