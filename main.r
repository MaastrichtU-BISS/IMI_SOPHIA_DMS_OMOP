# install.packages(c("RPostgreSQL", "rjson", "foreign", "xlsx"))

rm(list=ls())
library(RPostgreSQL)
library(rjson)
library(foreign)
library(data.table)
library(xlsx)

# setwd("P:/SOPHIA_shared_space/OMOP_CDM/Software/R-scripts")
setwd("L:/DMS/SOPHIA_shared_space/OMOP_CDM/Software/R-scripts")

## Verbinden met Maastricht Study SOPHIA OMOP-database.

# lezen van configuratie file (met usernames/passwords e.d.)
config <- fromJSON(file = "config.json")

# Hier wordt de daadwerkelijke database verbinding gemaakt
connection = dbConnect(dbDriver(config$driver),
                       host = config$host,
                       port = config$port,
                       user = config$username,
                       password = config$password,
                       dbname = config$databaseName)

source("99_read_data.r")

################################################################################
# Truncate database (clear)
################################################################################

source("00_load_mappings.r")
source("00_load_custom_sql_functions.r")
source("00_truncate.r")

################################################################################
# Load patients / persons
################################################################################

source("01_person.r")

# Get results from database
results_new <- dbGetQuery(connection, "SELECT * FROM person")

################################################################################
# Disconnect from database
################################################################################

dbDisconnect(connection)