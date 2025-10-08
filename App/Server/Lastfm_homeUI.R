library(shiny)
library(shinydashboard)
library(DT)

homeUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Top value boxes
    fluidRow(
      valueBoxOutput(ns("total_tracks")),
      valueBoxOutput(ns("top_artist")),
      valueBoxOutput(ns("listening_hours"))
    ),
    
    br(),
    
    # Top 5 artists
    h3("Your Top 5 Artists"),
    uiOutput(ns("top_artists")),
    
    br(),
    
    # Top 15 tracks
    h3("Your Top 15 Tracks"),
    DT::dataTableOutput(ns("top_tracks"))
  )
}
