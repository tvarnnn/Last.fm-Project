library(shiny)
library(shinydashboard)

source("../server/Lastfm_homeUI.R")   # module UI
source("../server/home_server.R")     # module server

ui <- dashboardPage(
  dashboardHeader(title = "Last.fm Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home"))
    )
  ),
  dashboardBody(
    tabItems(
      # Only ONE tabItem here, homeUI() provides the contents
      tabItem(tabName = "home", homeUI("home1"))
    )
  )
)

server <- function(input, output, session) {
  homeServer("home1")
}

shinyApp(ui, server)
