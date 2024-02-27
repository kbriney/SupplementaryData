
library(tidyverse)
library(stringr)

# Relevant file paths, change as necessary
fpath <- getwd()
fname <- "5-sampling.csv"



# ERROR SAMPLING #

# Read error sampling file
finput <- paste(fpath, fname, sep="/")
errSample <- read_csv(finput, col_types = cols(
  HasDataLink = col_logical(),
  CurationError = col_logical(),
  DataLinkError = col_logical(),
  DataLinkErrorSI = col_logical(),
  DataLinkErrorMissing = col_logical(),
  SI = col_logical()
))



# Average of articles with supplemental information
SIPerYear <- group_by(errSample, Year, SI) %>% 
  filter(SI == "TRUE") %>% count()
SIPerYear_avg <- as_tibble(pull(SIPerYear, n)) %>% 
  summarize(avg = mean(value)*2) %>% as.double()

# Total supplemental data links in sample per year
dataLinksPerYear <- group_by(errSample, Year, HasDataLink) %>% 
  filter(HasDataLink == "FALSE") %>%
  count() %>% mutate(dataLink = 50-n)



# Summarize curation errors per year

# Total curation errors in sample per year
curationErrorsPerYear <- group_by(errSample, Year, CurationError) %>% 
  filter(CurationError == "FALSE") %>%
  count() %>% mutate(curationError = 50-n)

# Total errors in curation of data links
# (Either missing data links or counting SI as a data link)
dataLinkErrorsPerYear <- group_by(errSample, Year, DataLinkError) %>% 
  filter(DataLinkError == "FALSE") %>%
  count() %>% mutate(dataLinkError = 50-n)

# Total error where SI is counted as a data link
dataLinkErrorsSIPerYear <- group_by(errSample, Year, DataLinkErrorSI) %>% 
  filter(DataLinkErrorSI == "FALSE") %>%
  count() %>% mutate(dataLinkErrorSI = 50-n)

# Total error where data link was missing
dataLinkMissingErrorsPerYear <- group_by(errSample, Year, DataLinkErrorMissing) %>% 
  filter(DataLinkErrorMissing == "FALSE") %>%
  count() %>% mutate(dataLinkErrorMissing = 50-n)



# Combine error counts in one large table
DLYear <- as_tibble(pull(dataLinkErrorsPerYear, Year)) %>% rename(Year = value)
DLErr <- as_tibble(pull(dataLinkErrorsPerYear, dataLinkError))  %>% rename(DataLinkError = value)
DLSIErr <- as_tibble(pull(dataLinkErrorsSIPerYear, dataLinkErrorSI))  %>% rename(DataLinkErrorSI = value)
DLMErr <- as_tibble(pull(dataLinkMissingErrorsPerYear, dataLinkErrorMissing))  %>% rename(DataLinkErrorMissing = value)

errorPerYear <- bind_cols(DLYear, DLErr, DLSIErr, DLMErr)

# Total curation error rate
errorPerYear_avg <- as_tibble(pull(errorPerYear, DataLinkError)) %>% 
  summarize(avg = mean(value)*2/100) %>% as.double()

# Error rate of including SI
errorPerYear_SI <- as_tibble(pull(errorPerYear, DataLinkErrorSI)) %>% 
  summarize(avg = mean(value)*2/100) %>% as.double()

# Error rate of missing data links
errorPerYear_missing <- as_tibble(pull(errorPerYear, DataLinkErrorMissing)) %>% 
  summarize(avg = mean(value)*2/100) %>% as.double()




# MEASURE STANDARD ERROR #

fname <- "5-resolves.csv"

finput <- paste(fpath, fname, sep="/")
resolve <- read_csv(finput)

resolve <- select(resolve, year, Resolves) %>% filter(year >= 2014) %>% filter(year <= 2022)
resolve_ct <- group_by(resolve, year) %>% count()
resolve_avg <- group_by(resolve, year) %>% summarise(avg = mean(Resolves))
resolve_stdv <- group_by(resolve, year) %>% summarise(stdv = sd(Resolves))

resolve_year <- as_tibble(pull(resolve_ct, year)) %>% rename(year = value)
resolve_ct <- as_tibble(pull(resolve_ct, n)) %>% rename(n = value)
resolve_avg <- as_tibble(pull(resolve_avg, avg)) %>% rename(avg = value)
resolve_stdv <- as_tibble(pull(resolve_stdv, stdv)) %>% rename(stdv = value)

resolve_err <- bind_cols(resolve_year, resolve_ct, resolve_avg, resolve_stdv)

# Calculate standard error
resolve_err <- mutate(resolve_err, SE = stdv/sqrt(n))

# Add in curation error rate
resolve_err <- mutate(resolve_err, totErr = SE + errorPerYear_avg)







#dataRot <- tibble(year = c(1:9),
#available = c(0.987, 0.959, 0.940, 0.956, 0.902, 0.792, 0.825, 0.887, 0.721),
#sterr = c(0.00454, 0.00730, 0.01216, 0.01926, 0.04205, 0.08468, 0.05083, 0.04394, 0.06921))

#dataRot <- mutate(dataRot, err_plus=(available+sterr+0.019), err_minus=(available-sterr-0.019))

#xlab <- tibble(c(2022:2014))

#ggplot(dataRot, aes(year, available, ymax=err_plus, ymin=err_minus)) + 
#  geom_col() +
#  geom_errorbar() +
#  scale_x_discrete(breaks=NULL, labels = xlab)
