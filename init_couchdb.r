require(jsonlite)
require(dplyr)
require(sofa)

data_path = "data/icml2016"

# read data
#====================
readLines(file.path(data_path, "authors.json")) %>% 
  paste( collapse="")

papers = readLines(file.path(data_path, "papers.json")) %>% 
  paste( collapse="") %>% 
  fromJSON() %>% 
  tbl_df()

authors = readLines(file.path(data_path, "authors.json")) %>% 
  paste( collapse="") %>% 
  fromJSON() %>% 
  tbl_df()

sessions = readLines(file.path(data_path, "sessions.json")) %>% 
  paste( collapse="") %>% 
  fromJSON() %>% 
  tbl_df()

# write to couchDB
#=============================
cdb = Cushion$new()

ping(cdb)
db_list(cdb)

if ("items" %in% db_list(cdb)) 
  cdb %>% db_delete("items")
cdb %>% db_create("items")
cdb %>% db_bulk_create("items", apply(papers, 1, function(x) toJSON(x, auto_unbox=TRUE)))

if ("authors" %in% db_list(cdb)) 
  cdb %>% db_delete("authors")
cdb %>% db_create("authors")
cdb %>% db_bulk_create("authors", apply(authors, 1, function(x) toJSON(x, auto_unbox=TRUE)))

if ("sessions" %in% db_list(cdb)) 
  cdb %>% db_delete("sessions")
cdb %>% db_create("sessions")
cdb %>% db_bulk_create("sessions", apply(sessions, 1, function(x) toJSON(x, auto_unbox=TRUE)))
