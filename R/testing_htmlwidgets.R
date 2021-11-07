library(tidyverse)
library(leaflet)


l <- leaflet() %>% addTiles()
htmlwidgets::saveWidget(l, "site/maps/test_saveWidget.html", libdir = "map_libs")


targets::tar_load(map_ottawa_fr)


htmlwidgets::saveWidget(map_ottawa_fr, "site/maps/ottawa_fr.html", selfcontained = TRUE,
                        height 
                        knitrOptions= list(
                          out.width = "1000px",
                          out.height = "1000px"
                        )
                        )

htmlwidgets::createWidget(t, map_ottawa_fr)
map_ottawa_fr


##############
targets::tar_load(c(docs_ottawa_file, map_langs))
source("R/map_making.R")

z <-   make_docmap(data_file = docs_ottawa_file,
              map_language = "FR",
              lang_data = map_langs)
htmlwidgets::saveWidget(z, "site/maps/ottawa_fr.html",
                        libdir = "map_libs")
