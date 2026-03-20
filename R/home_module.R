library(shiny)
library(shinydashboard)
library(DT)

homeUI <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      valueBoxOutput(ns("total_tracks")),
      valueBoxOutput(ns("top_artist")),
      valueBoxOutput(ns("listening_hours"))
    ),

    fluidRow(
      valueBoxOutput(ns("current_streak")),
      valueBoxOutput(ns("longest_streak"))
    ),

    br(),

    h3("Your Top 5 Artists"),
    uiOutput(ns("top_artists")),

    br(),

    h3("Listening Clock"),
    fluidRow(
      box(
        width = 8,
        solidHeader = TRUE, status = "primary",
        plotOutput(ns("clock"), height = "550px")
      )
    ),

    br(),

    h3("Your Top 15 Tracks"),
    DT::dataTableOutput(ns("top_tracks"))
  )
}

homeServer <- function(id, top15_tracks, all_tracks) {
  moduleServer(id, function(input, output, session) {

    homeData <- getHomeData(all_tracks)
    streaks  <- streak_stats(all_tracks)

    output$total_tracks <- renderValueBox({
      valueBox(homeData$totalTracks, "Total Tracks", icon = icon("music"), color = "blue")
    })

    output$top_artist <- renderValueBox({
      valueBox(homeData$topArtist, "Top Artist", icon = icon("user"), color = "blue")
    })

    output$listening_hours <- renderValueBox({
      valueBox(homeData$listeningHours, "Listening Hours", icon = icon("clock"), color = "blue")
    })

    output$current_streak <- renderValueBox({
      valueBox(paste(streaks$current_streak, "days"), "Current Streak", icon = icon("fire"), color = "orange")
    })

    output$longest_streak <- renderValueBox({
      valueBox(paste(streaks$longest_streak, "days"), "Longest Streak", icon = icon("trophy"), color = "yellow")
    })

    output$top_artists <- renderUI({
      artists <- homeData$topArtistsDF
      if (nrow(artists) == 0) return(tags$p("No artist data available"))

      fluidRow(
        lapply(1:nrow(artists), function(i) {
          artist <- artists[i, ]
          box(
            title = artist$`artist..text`,
            status = "primary",
            solidHeader = TRUE,
            width = 2,
            collapsible = FALSE,
            tags$img(src = artist$image_url, height = "100px"),
            tags$p(paste("Plays:", artist$plays))
          )
        })
      )
    })

    output$clock <- renderPlot({
      listening_trends(all_tracks)
    })

    output$top_tracks <- DT::renderDataTable({
      DT::datatable(top15_tracks, options = list(pageLength = 15, dom = "t"), rownames = FALSE)
    })

  })
}
