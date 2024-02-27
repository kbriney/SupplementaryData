# An analysis of supplementary data links in CaltechAUTHORS, stage 5:
#   Creating figures. Figure 1 is count of datasets graphed by article age.
#   Figure 2 is availability of datasets as a function of article age, modelled
#   with a logistical regression fit.
# Kristin A. Briney
# 2024-02

library(tidyverse)
library(stringr)
library(modelr)

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
  summarize(avg = mean(value)/50) %>% as.double()
# Divide values by 50 to get a percentage, as there are 50 samples per year

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

# These are calculated using the FALSE values as there are always FALSE values
# each year (not all years have TRUE values), so this give complete representation
# of all years. Then count of FALSE is subtracted from 50 to give count of TRUE,
# as there are 50 articles sampled each year.



# Combine error counts in one large table
DLYear <- as_tibble(pull(dataLinkErrorsPerYear, Year)) %>% rename(Year = value)
DLErr <- as_tibble(pull(dataLinkErrorsPerYear, dataLinkError))  %>% rename(DataLinkError = value)
DLSIErr <- as_tibble(pull(dataLinkErrorsSIPerYear, dataLinkErrorSI))  %>% rename(DataLinkErrorSI = value)
DLMErr <- as_tibble(pull(dataLinkMissingErrorsPerYear, dataLinkErrorMissing))  %>% rename(DataLinkErrorMissing = value)

errorPerYear <- bind_cols(DLYear, DLErr, DLSIErr, DLMErr)

# Total curation error rate
errorPerYear_avg <- as_tibble(pull(errorPerYear, DataLinkError)) %>% 
  summarize(avg = mean(value)/50) %>% as.double()

# Error rate of including SI
errorPerYear_SI <- as_tibble(pull(errorPerYear, DataLinkErrorSI)) %>% 
  summarize(avg = mean(value)/50) %>% as.double()

# Error rate of missing data links
errorPerYear_missing <- as_tibble(pull(errorPerYear, DataLinkErrorMissing)) %>% 
  summarize(avg = mean(value)/50) %>% as.double()

# Divide these values by 50 to get a percentage, as there are 50 samples per year




# MEASURE STANDARD ERROR #

fname <- "5-resolves.csv"

finput <- paste(fpath, fname, sep="/")
resolve <- read_csv(finput)

# Get summary statistics (count, average, st dev)
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
resolve_err <- mutate(resolve_err, errPlus = SE + errorPerYear_avg)
resolve_err <- mutate(resolve_err, errMinus = SE + errorPerYear_avg)





# FIGURE 1 #

fig1 <- filter(resolve_err, year>2000)
fig1 <- add_column(fig1, age=21:0)

ggplot(fig1, aes(age, n, label=n)) + 
  geom_col() +
  geom_text(nudge_y = 12) +
  scale_x_continuous(breaks = seq(0, 21, by = 1)) +
  labs(x="Age of article in years", y="Number of data sets")



# Save figure output
fname <- "figure1.tif"
ggsave(fname, plot = last_plot())




# FIGURE 2 #

# Prep data to model
#resolve_model <- mutate(resolve, gone=1-Resolves)
resolve_model <- filter(resolve_model, year >= 2014) %>% filter(year <= 2022)
resolve_model <- mutate(resolve_model, age=2023-year)



# Fit to logistic regression
fig2_model <- glm(Resolves ~ age, family=binomial, data=resolve_model)
summary(fig2_model)

# Create probabilities based on model for graphing
fig2_ages <- data.frame(age=9:1)
fig2_fit <- as_tibble(predict(fig2_model, newdata=fig2_ages, type="response"))
fig2_fit <- rename(fig2_fit, prob=value)



# Interpret coefficient values
coefs <- as_tibble(coef(fig2_model))
coefs <- slice(coefs,2)

model_coefs <- as_tibble(exp(coef(fig2_model)))
model_coefs <- slice(model_coefs,2)

model_coefs <- rename(model_coefs, age=value)
model_coefs <- mutate(model_coefs, CIupper= exp(coefs$value+(1.96*errorPerYear_avg)))
model_coefs <- mutate(model_coefs, CIlower= exp(coefs$value-(1.96*errorPerYear_avg)))



# Create plot

# Only plot 2014-2022
fig2 <- filter(resolve_err, year >= 2014) %>% filter(year <= 2022)

# Plot by age in year
fig2 <- mutate(fig2, age=2023-year)

# Show labels to 3 decimal places
fig2 <- mutate(fig2, lbl = (round(avg*10^3)/10^3))

# Add probabilities to tibble
fig2 <- add_column(fig2, fig2_fit)
#fig2 <- mutate(fig2, invProb = 1-prob)



# Plot data and model
ggplot(data=fig2, mapping=aes(x=age, y=avg, ymax=(avg+errPlus), ymin=(avg-errMinus), label=lbl)) + 
  geom_col() +
  geom_text(nudge_y = 0.015) +
  geom_errorbar() +
  geom_line(data=fig2, mapping=aes(x=age, y=prob)) +
  scale_x_continuous(breaks = seq(1, 9, by = 1)) +
  scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
  labs(x="Age of article in years", y="Percent of data sets available")



# Save figure output
fname <- "figure2.tif"
ggsave(fname, plot = last_plot())

