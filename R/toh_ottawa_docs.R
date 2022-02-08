# small script to find physicians from the ottawa hospital
# in response to email request from Lise,  Jan 26 2022, at request of
# Nandrianina Andriamanantena <nandria2@uottawa.ca> 
# Subject: Médecins parlant français à TOH
library(tidyverse)

docs_ottawa_2021_06_30 <- read_csv("data/docs_ottawa_2021-06-30.csv")

docs <- docs_ottawa_2021_06_30         

toh_docs_fr <- docs %>%
  filter(stringr::str_detect(primary_location, "The Ottawa Hospital|TOH")) %>%
  filter(stringr::str_detect(languages_spoken, "French")) %>%
  select(cpso, name_last, name_first, languages_spoken, specialties, primary_location) %>%
  mutate(specialties = stringr::str_remove_all(specialties, "Effective:.*"),
         specialties = stringr::str_replace_all(specialties, "\\s*\\n", ", ")) %>%
  arrange(specialties)

write_csv(toh_docs_fr, "data/toh_docs_fr_2022-01-26.csv")
