library(dplyr)
library(stringr)

getHomeData <- function(tracks, top_n = 5, avg_minutes = 3.5) {
  
  # Add minutes column if missing
  if(!"minutes" %in% names(tracks)) {
    tracks <- tracks %>% mutate(minutes = avg_minutes)
  }
  
  # Extract largest image URL from 'image' column
  tracks <- tracks %>%
    mutate(image_url = str_extract(image, "https://[^\\)\"]+300x300[^\\)\"]+"))
  
  # Top artists
  topArtistsDF <- tracks %>%
    group_by(`artist..text`) %>%
    summarise(
      plays = n(),
      image_url = first(image_url),
      total_minutes = sum(minutes),
      .groups = "drop"
    ) %>%
    arrange(desc(plays)) %>%
    head(top_n)
  
  # Total tracks
  total_tracks <- nrow(tracks)
  
  # Listening hours in days + hours
  total_hours <- sum(topArtistsDF$total_minutes)/60
  listening_hours <- if(total_hours >= 24) {
    days <- floor(total_hours / 24)
    hrs <- round(total_hours %% 24, 1)
    paste(days, "days", hrs, "hrs")
  } else {
    paste(round(total_hours, 1), "hrs")
  }
  
  # Top artist
  top_artist <- if(nrow(topArtistsDF) > 0) topArtistsDF$`artist..text`[1] else NA
  
  list(
    topArtistsDF = topArtistsDF,
    totalTracks = total_tracks,
    listeningHours = listening_hours,
    topArtist = top_artist
  )
}
