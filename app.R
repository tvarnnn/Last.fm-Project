library(shiny)
library(shinydashboard)
library(here)
library(httr)
library(jsonlite)
library(dplyr)

source(here("R", "analysis.R"))
source(here("R", "home_module.R"))
source(here("R", "tabs_module.R"))

user     <- Sys.getenv("LASTFM_USER")
api_key  <- Sys.getenv("LASTFM_API_KEY")
csv_file <- here("data", "all_tracks.csv")

if (!dir.exists(here("data"))) dir.create(here("data"))

# ── Fetch function (used on startup and by the Refresh button) ────────────────

fetch_from_lastfm <- function() {
  message("Fetching scrobbles from Last.fm...")
  if (file.exists(csv_file)) file.remove(csv_file)

  limit <- 1000
  page <- 1
  total_pages <- 1

  repeat {
    url <- paste0(
      "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=",
      user, "&api_key=", api_key, "&format=json&limit=", limit, "&page=", page
    )

    response <- GET(url)
    content <- fromJSON(content(response, "text"), flatten = TRUE)
    tracks <- content$recenttracks$track

    tracks_df <- as.data.frame(tracks, stringsAsFactors = FALSE)

    for (col in names(tracks_df)) {
      if (is.list(tracks_df[[col]])) {
        tracks_df[[col]] <- sapply(tracks_df[[col]], function(x) {
          if (length(x) == 0) return(NA)
          paste(x, collapse = "; ")
        })
      }
    }

    write.table(
      tracks_df, csv_file, sep = ",",
      row.names = FALSE, col.names = (page == 1), append = (page > 1)
    )

    total_pages <- as.numeric(content$recenttracks[["@attr"]]$totalPages)
    message("Fetched page ", page, " of ", total_pages)

    if (page >= total_pages) break
    page <- page + 1
  }

  message("All tracks saved.")
}

# Fetch on first run if no CSV exists
if (!file.exists(csv_file)) fetch_from_lastfm()

# ── Load and pre-parse dates once ─────────────────────────────────────────────

all_tracks <- read.csv(csv_file, stringsAsFactors = FALSE) %>%
  mutate(
    date.uts = as.numeric(date.uts),
    play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"),
    year  = format(play_date, "%Y"),
    month = as.numeric(format(play_date, "%m"))
  ) %>%
  filter(!is.na(play_date))

# Compute top 15 tracks directly — no console print
top15_tracks <- all_tracks %>%
  group_by(name, `artist..text`) %>%
  summarize("Play count" = n(), .groups = "drop") %>%
  arrange(desc(`Play count`)) %>%
  rename(Track = name, Artist = `artist..text`) %>%
  head(15)

# ── UI ────────────────────────────────────────────────────────────────────────

ui <- dashboardPage(
  dashboardHeader(title = "Last.fm Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home",    tabName = "home",    icon = icon("home")),
      menuItem("Artists", tabName = "Artists", icon = icon("user")),
      menuItem("Albums",  tabName = "Albums",  icon = icon("compact-disc")),
      menuItem("Tracks",  tabName = "Tracks",  icon = icon("music")),
      menuItem("History", tabName = "History", icon = icon("calendar"))
    ),
    hr(),
    div(style = "text-align: center; padding: 10px;",
      actionButton("refresh_data", "Refresh Data", icon = icon("sync"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "home",    homeUI("home1")),
      tabItem(tabName = "Artists", artistsUI("artists1")),
      tabItem(tabName = "Albums",  albumsUI("albums1")),
      tabItem(tabName = "Tracks",  tracksUI("tracks1")),
      tabItem(tabName = "History", historyUI("history1"))
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────

server <- function(input, output, session) {
  homeServer("home1",       top15_tracks, all_tracks)
  artistsServer("artists1", all_tracks)
  albumsServer("albums1",   all_tracks)
  tracksServer("tracks1",   all_tracks)
  historyServer("history1", all_tracks)

  observeEvent(input$refresh_data, {
    showModal(modalDialog(
      title = "Refreshing Data",
      "Fetching your latest scrobbles from Last.fm. This may take a moment...",
      footer = NULL,
      easyClose = FALSE
    ))
    fetch_from_lastfm()
    session$reload()
  })
}

shinyApp(ui, server)
