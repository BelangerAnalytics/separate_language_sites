
# FIXME! PUT TARGET ONE CALL PER LOCATION THIS WILL MAKE THE MAPS
make_docmaps_forweb <- function(data_file, lang_data){
  # loop through two langauges, render maps
  for (lang in c("en", "fr")){
    
  make_docmap(data_file = data_file,
              map_language = toupper(lang),
              lang_data = map_langs) %>%
    htmlwidgets::saveWidget(file = sprintf("site_%s/maps/ottawa_%s.html", lang, lang),
                            libdir = "map_libs") 
  
  }
}



make_docmap <- function(data_file, # = "data/docs_ottawa",
                        map_language = c("EN","FR"),
                        lang_data,
                        verbose = FALSE){

  # parse our input language
  map_language <- toupper(map_language)
  map_language = match.arg(map_language, map_language)
  if (verbose) message(map_language)
  if (!map_language %in% c("EN", "FR")) stop("`map_language` must be 'EN' or 'FR'.")

  # load the physician data
  docs_all <- read_csv(data_file,
                       col_types = cols(.default = "c")) %>%
    mutate(lat = as.double(lat),
           lng = as.double(lng)
   #         ,
   #         french = as.logical(french),
   #         family_physician = as.logical(family_physician),
   #         in_geo_scope = as.logical(in_geo_scope)) %>%
   # # filter(in_geo_scope & family_physician)
   #  filter(family_physician)  %>%
   #  mutate(phone = stringr::str_extract(primary_location, "(?<=Phone: ).*"),
   #                                    fax = stringr::str_extract(primary_location, "(?<=Fax: ).*"),
   #                                    phone = stringr::str_remove_all(phone, " Electoral.*"),
   #                                    fax = stringr::str_remove_all(fax, " Electoral.*"),
   #                                    address = stringr::str_remove_all(primary_location, regex("(Phone|Fax|Electoral).*", dotall = TRUE))
           ) %>%
    filter(!is.na(languages_spoken))

  # set up English official languages
  official_languages <- c("English", "French")

  # IF we're doing a French map, translate all the languages right now
  if (map_language == "FR"){
    if (verbose) message("Detected French as official language.")
    official_languages <- c("Anglais", "Français")

    for (i in 1:nrow(lang_data)){
      docs_all <- docs_all %>%
        mutate(languages_spoken = stringr::str_replace(languages_spoken, lang_data[i,]$en, lang_data[i,]$fr))

    }
  }



  # extract the unique languages into a character vector
  langs <- docs_all$languages_spoken %>%
    stringr::str_flatten(collapse = ", ") %>%
    stringr::str_split(pattern = ", ") %>%
    unlist() %>%
    unique()

  # create a nested tibble with one row for each language, including the name of the
  # language and the physicians who speak it
  doc_nested <- tibble(language = langs) %>%
    mutate(docs = purrr::map(language, function(x) filter(docs_all, str_detect(languages_spoken, x)))) %>%
    mutate(count = purrr::map_dbl(docs, nrow),
           official_lang = language %in% official_languages) %>%
    arrange(desc(official_lang), language)

  # we also want an "All" option first on the list, even though it has the same
  # physicians as are listed under "English"
  doc_nested_all <- doc_nested[1,] %>%
    mutate(language = if_else(map_language == "EN", "All", "Toutes"))

  doc_nested <- bind_rows(doc_nested_all,
            doc_nested)

  docmap <- leaflet() %>% #(width="100%") %>%
    addTiles()

  ## LANGUAGE-SPECIFIC VARIABLES FOR MAP LABELS
  if (map_language == "EN"){
    langs_spoken <- "Languages Spoken"
    cpso_num <- "CPSO #"
    contact_information <- "Address"
    phone_num <- "Phone"
    fax_num <- "Fax"
  }
  if (map_language == "FR"){
    langs_spoken <- "Langues parlées"
    cpso_num <- "# CPSO"
    contact_information <- "Coordonnées"
    phone_num <- "Téléphone"
    fax_num <- "Fax"
  }


  for (i in 1:nrow(doc_nested)){
    lang <- doc_nested$language[[i]]
    docs <- doc_nested$docs[[i]]

    # make the labels
    map_labs <- paste0("<b><u>", doc_nested$docs[[i]]$doc_name,"</b></u>",
                       "<br><b>",langs_spoken,":</b> ", doc_nested$docs[[i]]$languages_spoken,
                       "<br><b>",cpso_num,":</b> ", doc_nested$docs[[i]]$cpso,
                       "<br><b>",contact_information,":</b><br>  ", stringr::str_replace_all(doc_nested$docs[[i]]$address, "\\n", "<br>  ")
                       # ,"<br><b>", phone_num,":</b> ", doc_nested$docs[[i]]$phone,
                       # "<br><b>", fax_num, ":</b> ", doc_nested$docs[[i]]$fax
    ) 
    
#    message(sum(is.na(doc_nested$docs[[i]]$phone)))

    # only add phone/fax if it's not NA
    
    phone_nums <- if_else(is.na(doc_nested$docs[[i]]$phone),
                          "",
                          paste0("<br><b>", phone_num,":</b> ", doc_nested$docs[[i]]$phone))
    fax_nums <- if_else(is.na(doc_nested$docs[[i]]$fax),
                          "",
                          paste0("<br><b>", fax_num,":</b> ", doc_nested$docs[[i]]$fax))
    map_labs <- paste0(map_labs, phone_nums, fax_nums)
    
    map_labs <- purrr::map(map_labs, htmltools::HTML)

    
    

    # make popups: the same as the labels, but including clickable addresses that go to google maps
    map_popups <-     paste0("<b><u>", doc_nested$docs[[i]]$doc_name,"</b></u>",
                         "<br><b>",langs_spoken,":</b> ", doc_nested$docs[[i]]$languages_spoken,
                         "<br><b>",cpso_num,":</b> ", doc_nested$docs[[i]]$cpso,
                         "<br><b>",contact_information,":</b>
                         <br><a href = 'https://google.com/maps/search/",  urltools::url_encode(stringr::str_replace_all(doc_nested$docs[[i]]$address, "\n", ", ")),
                         "' target='_blank'>", stringr::str_replace_all(doc_nested$docs[[i]]$address, "\\n", "<br>  "),"</a>",
                         #"<br><a href = 'https://google.com/maps/search/",  urltools::url_encode(stringr::str_replace_all(doc_nested$docs[[i]]$address, "\n", ", ")),
                         "<br><b>", phone_num,":</b> ", doc_nested$docs[[i]]$phone,
                         "<br><b>", fax_num, ":</b> ", doc_nested$docs[[i]]$fax
                         ) %>%
      purrr::map(htmltools::HTML)

    # add everything to the map
    docmap <- docmap %>%
      addMarkers(data = docs, lat = ~ lat, lng = ~ lng,
                 group = lang,
                 clusterOptions = markerClusterOptions(),
                 label = map_labs,
                 popup = map_popups)
  }

  docmap <- docmap %>%
    addLayersControl(baseGroups = doc_nested$language,
                     options = layersControlOptions(collapsed = FALSE))



  return(docmap)
}

 #t<- make_docmap(lang = "FR")
