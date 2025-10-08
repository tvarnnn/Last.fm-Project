# Load libraries
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(here)

# User config
user <- "ADD LASTFM USERNAME HERE"
api_key <- "ADD API KEY HERE"
csv_file <- here("data", "all_tracks.csv")

# Ensure data folder exists
if (!dir.exists(here("data"))) {
  dir.create(here("data"))
}

# Calling API
if (!file.exists(csv_file)) {
  
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
    
    # Convert to data frame
    tracks_df <- as.data.frame(tracks, stringsAsFactors = FALSE)
    
    # Flatten any list columns
    for (col in names(tracks_df)) {
      if (is.list(tracks_df[[col]])) {
        tracks_df[[col]] <- sapply(tracks_df[[col]], function(x) {
          if (length(x) == 0) return(NA)
          paste(x, collapse = "; ")
        })
      }
    }
    
    # Write to CSV (append if page > 1)
    write.table(
      tracks_df, csv_file, sep = ",",
      row.names = FALSE, col.names = (page == 1), append = (page > 1)
    )
    
    total_pages <- as.numeric(content$recenttracks[["@attr"]]$totalPages)
    cat("Fetched page", page, "of", total_pages, "\n")
    
    if (page >= total_pages) break
    page <- page + 1
  }
  
  cat("All tracks saved to", csv_file, "\n")
}

# Load the CSV
all_tracks <- read.csv(csv_file, stringsAsFactors = FALSE)

# Source analysis files
source(here("Scripts", "Lastfm_Yearly.R"))
source(here("Scripts", "Lastfm_Monthly.R"))
source(here("Scripts", "Lastfm_TopArtists.R"))
source(here("Scripts", "Lastfm_TopTracks.R"))
source(here("Scripts", "Lastfm_TopAlbums.R"))
source(here("Scripts", "Lastfm_ListeningTrends.R"))
source(here("Scripts", "Lastfm_VisualizingYearlyData.R"))

# Run analysis functions
yearly_stats(all_tracks)
monthly_stats(all_tracks)
top_artists(all_tracks)
top_tracks(all_tracks)
top_albums(all_tracks)
listening_trends(all_tracks)
