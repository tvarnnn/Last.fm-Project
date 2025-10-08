library(dplyr)
library(DT)

homeServer <- function(id, top15_tracks) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns  # namespace
    
    # --- Load Home Data ---
    tracks <- read.csv(here::here("data", "all_tracks.csv"), stringsAsFactors = FALSE)
    homeData <- getHomeData(tracks)   # now available
    
    # --- Value Boxes ---
    output$total_tracks <- renderValueBox({
      valueBox(homeData$totalTracks, "Total Tracks", icon = icon("music"), color = "blue")
    })
    
    output$top_artist <- renderValueBox({
      valueBox(homeData$topArtist, "Top Artist", icon = icon("user"), color = "blue")
    })
    
    output$listening_hours <- renderValueBox({
      valueBox(homeData$listeningHours, "Listening Hours", icon = icon("clock"), color = "blue")
    })
    
    # --- Top 5 Artists ---
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
    
    # --- Top 15 Tracks ---
    output$top_tracks <- DT::renderDataTable({
      DT::datatable(top15_tracks, options = list(pageLength = 15, dom = "t"), rownames = TRUE)
    })
    
  })
}
