Data files from the article "Measuring Data Rot" by Kristin Briney.

Data in the tables:
- Table1_LinkType.csv
- Table2_URLwebsites.csv
- Table3_DOIwebsites.csv
- Table4_UnavailableByType.csv
- Table5_UnavailableURLs.csv
- Table6_UnavailableDOIs.csv

Data in the figures:
- Figure1_LinksByYear.csv
- Figure2_UnavailableByYear.csv

Data from the project:
- DataRot.csv
	Overall dataset supporting this research, with variables defined in the data dictionary. This data contains all of the links tested, listing results of the webscraping but not results of the hand testing.
- DataRot_dataDictionary.csv
	Data dictionary defining variable names and values for DataRot.csv
- DataRot_handTested.csv
	Subset supplemental data links from DataRot.csv that were handtested and the results of the hand testing ("browser_test = TRUE" means the data was available, "browser_test = FALSE" means the data was not available, and "browser_test = LOGIN" means the webpage asked for a login to see the data).
- DataRot_missingData.csv
	Subset of DataRot_handTested.csv with fewer variables. This dataset only includes supplemental data links for data that was not available.
