library(tidyverse, warn.conflicts = FALSE)
library(plotly)
library(labelled)
library(gt)
library(gtsummary)
library(DBI)
library(RMariaDB)
library(pool)
library(DT)
library(shiny)
library(shinymanager)
library(shinyFeedback)
library(shinybusy)
library(shinyjs)
library(shinycssloaders)
library(shinyWidgets)
library(bslib)
library(bsicons)
library(Minirand)

options(
  spinner.type = 6
)

shiny_files <- list.files(
  path = 'R',
  pattern = '\\.R$',
  recursive = TRUE,
  full.names = TRUE
)

lapply(shiny_files, source)

source('app_ui.R')
source('app_server.R')



shinyApp(ui = ui, server = server)