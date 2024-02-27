
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

resolve <- select(resolve, year, Resolves) %>% filter(year >0)
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

# Add in curation error rates
resolve_err <- mutate(resolve_err, errPlus = SE + errorPerYear_missing)
resolve_err <- mutate(resolve_err, errMinus = SE + errorPerYear_SI)



# FIGURE 1 #

fig1 <- filter(resolve_err, year>2000)
fig1 <- add_column(fig1, age=21:0)

ggplot(fig1, aes(age, n, label=n)) + 
  geom_col() +
  geom_text(nudge_y = 12) +
  scale_x_continuous(breaks = seq(0, 21, by = 1)) +
  labs(x="Age of article in years", y="Number of data sets")


# FIGURE 2 #

fig2 <- filter(resolve_err, year >= 2014) %>% filter(year <= 2022)
fig2 <- add_column(fig2, age=9:1)

ggplot(fig2, aes(age, avg, ymax=(avg+errPlus), ymin=(avg-errMinus))) + 
  geom_col() +
  geom_errorbar() +
  scale_x_continuous(breaks = seq(1, 9, by = 1)) +
  labs(x="Age of article in years", y="Percent of data sets available")



