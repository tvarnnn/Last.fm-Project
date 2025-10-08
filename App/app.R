library(shiny)
library(shinydashboard)
library(here) 

# Call backend scripts
source(here("Scripts", "Lastfm_TopTracks.R"))          # loads track_counts
source(here("Scripts", "Lastfm_HomedataBackend.R"))    # defines getHomeData()

# Compute top 15 tracks
top15_tracks <- head(track_counts, 15)

# Call server and UI models
source(here("App", "server", "home_server.R"))
source(here("App", "server", "Lastfm_homeUI.R"))

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Last.fm Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Artists", tabName = "Artists", icon = icon("user")),
      menuItem("Albums", tabName = "Albums", icon = icon("compact-disc")),
      menuItem("Tracks", tabName = "Tracks", icon = icon("music"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "home", homeUI("home1")),
      
      tabItem(tabName = "Artists", h2("Artist data coming soon!")),
      
      tabItem(tabName = "Albums", h2("Album data coming soon!")),
      
      tabItem(tabName = "Tracks", h2("Track data coming soon!"))
    )
  )
)

# Define Server
server <- function(input, output, session) {
  # Pass Top 15 tracks into the module
  homeServer("home1", top15_tracks)
}

# Run app
shinyApp(ui, server)
