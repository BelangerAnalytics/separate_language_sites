#_targets.R
# load the two packages we need to run targets and generate Rmd files
### TO ADD A NEW SET OF MAPS
#  STEP 1: Add the data in csv format to the "data" folder. Make sure it has the 
#          same columns as the others. (TODO: Document this fully. For now 
#          just copy.)
#  STEP 2: Add tar_target() entries for english and french maps below.
#  STEP 3: Add English and French entries to the "site/index.Rmd" file, using
#          one of the other cities as a template and making the needed changes.
#  STEP 4: Render "site/index.Rmd" 
#  STEP 5: Copy the entire "site" folder to the hosting service you're using.


library(targets)
library(tarchetypes)


options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("tidyverse",
                            "httr",
                            "rvest",
                            "sf",
                            "leaflet",
                            "jsonlite",
                            "htmlwidgets",
                            #"RSelenium",  # needed only for scraping
                            #"wdman",
                            "htmltools"))
source("R/map_making.R", encoding = "UTF-8")
#source("R/parse_grocers.R")

list(

  # language names in English and French. Update this if you get new languages
  # in new regions.
  tar_target(
    lang_file,
    "data/langs.csv",
    format = "file"
  ),
  
  tar_target(
    map_langs,
    readr::read_csv(lang_file)
  ),
  
  
  ### OTTAWA
  
  tar_target(
    docs_ottawa_file,
      "data/docs_ottawa_mapclean_2023-01-06.csv",
    format = "file"
  ),

  tar_target(maps_ottawa,
             make_docmaps_forweb(docs_ottawa_file, "ottawa", map_langs)),
  
  # tar_target(
  #   map_ottawa_en,
  #   make_docmap(data_file = docs_ottawa_file,
  #               map_language = "EN",
  #               lang_data = map_langs) %>%
  #     htmlwidgets::saveWidget(file = "site_en/maps/ottawa_en.html",
  #                             libdir = "map_libs") 
  #   
  # ),
  # 
  # tar_target(
  #   map_ottawa_fr,
  #   make_docmap(data_file = docs_ottawa_file,
  #               map_language = "FR",
  #               lang_data = map_langs) %>%
  #     htmlwidgets::saveWidget(file = "site_fr/maps/ottawa_fr.html",
  #                             libdir = "map_libs")
  # ),
  

  
  ### RENFREW COUNTY
  
  tar_target(
    docs_renfrew_file,
    "data/docs_renfrew_2021-08-17.csv",
    format = "file"
  ),
  
  tar_target(maps_renfrew,
             make_docmaps_forweb(docs_renfrew_file, "renfrew", map_langs)),
  
  
  ## ALBERTA
  
  
  tar_target(
    docs_alberta_file,
    "data/AB-docs-clean-geocoded-filtered-docmapper-2023-03-02.csv",
    format = "file"
  ),
  
  tar_target(maps_alberta,
             make_docmaps_forweb(docs_alberta_file, "alberta", map_langs)),
  
  # tar_target(
  #   map_renfrew_en,
  #   make_docmap(data_file = docs_renfrew_file,
  #               map_language = "EN",
  #               lang_data = map_langs) %>%
  #     htmlwidgets::saveWidget(file = "site_en/maps/renfrew_en.html",
  #                             libdir = "map_libs") 
  # ),
  # 
  # tar_target(
  #   map_renfrew_fr,
  #   make_docmap(data_file = docs_renfrew_file,
  #               map_language = "FR",
  #               lang_data = map_langs) %>%
  #     htmlwidgets::saveWidget(file = "site_fr/maps/renfrew_fr.html",
  #                             libdir = "map_libs")
  #   ),

 
  ### render the indexes
  tarchetypes::tar_render(index_en,
                          "site_en/index.Rmd"),
  tarchetypes::tar_render(index_fr,
                          "site_fr/index.Rmd"),
   
  NULL
)