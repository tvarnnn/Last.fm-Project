library(dplyr)
library(ggplot2)
library(stringr)

yearly_stats <- function(tracks) {
  tracks$date.uts <- as.numeric(tracks$date.uts)

  result <- tracks %>%
    mutate(
      play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"),
      year = format(play_date, "%Y")
    ) %>%
    filter(!is.na(play_date)) %>%
    group_by(year) %>%
    summarise(total_tracks = n(), .groups = "drop") %>%
    arrange(year)

  print(result)
  invisible(result)
}

monthly_stats <- function(tracks) {
  tracks$date.uts <- as.numeric(tracks$date.uts)

  result <- tracks %>%
    mutate(
      play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"),
      year = format(play_date, "%Y"),
      month = format(play_date, "%m")
    ) %>%
    filter(!is.na(play_date)) %>%
    group_by(year, month) %>%
    summarise(total_scrobbles = n(), .groups = "drop") %>%
    arrange(year, month)

  print(result, n = 52)
  invisible(result)
}

top_artists <- function(tracks) {
  artists_counts <- tracks %>%
    group_by(`artist..text`) %>%
    summarise(total_tracks = n(), .groups = "drop") %>%
    arrange(desc(total_tracks))

  top5 <- head(artists_counts, 5)
  misc_count <- sum(artists_counts$total_tracks) - sum(top5$total_tracks)
  top5 <- rbind(top5, data.frame(`artist..text` = "Misc", total_tracks = misc_count, check.names = FALSE))

  top5 <- top5 %>%
    mutate(legend_label = paste0(`artist..text`, " (", round(100 * total_tracks / sum(total_tracks), 1), "%)"))

  p <- ggplot(top5, aes(x = "", y = total_tracks, fill = legend_label)) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y", start = 0) +
    labs(title = "Top 5 Artists by Plays") +
    theme_void() +
    theme(legend.title = element_blank())

  print(p)
  invisible(top5)
}

top_tracks <- function(tracks, top_n = 100) {
  result <- tracks %>%
    group_by(name, `artist..text`) %>%
    summarize(total_scrobbles = n(), .groups = "drop") %>%
    arrange(desc(total_scrobbles)) %>%
    rename(
      Track = name,
      Artist = `artist..text`,
      "Play count" = total_scrobbles
    )

  print(head(result, top_n))
  invisible(result)
}

top_albums <- function(tracks, top_n = 100) {
  result <- tracks %>%
    group_by(`artist..text`, `album..text`) %>%
    summarise(play_count = n(), .groups = "drop") %>%
    arrange(desc(play_count)) %>%
    head(top_n) %>%
    rename(
      Artist = `artist..text`,
      Album = `album..text`,
      "Play Count" = play_count
    )

  print(result)
  invisible(result)
}

listening_trends <- function(tracks) {
  tracks$date.uts <- as.numeric(tracks$date.uts)

  tracks <- tracks %>%
    mutate(hour = as.numeric(format(as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"), "%H"))) %>%
    filter(!is.na(hour))

  hourly_stats <- tracks %>%
    group_by(hour) %>%
    summarise(total_scrobbles = n(), .groups = "drop")

  p <- ggplot(hourly_stats, aes(x = factor(hour), y = total_scrobbles)) +
    geom_bar(stat = "identity", fill = "red") +
    coord_polar(start = -pi/2) +
    scale_x_discrete(labels = 0:23) +
    labs(title = "Music Listening by Hour of the Day", x = "", y = "") +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      plot.title = element_text(hjust = 0.5)
    )

  print(p)
  invisible(p)
}

visualize_yearly <- function(tracks) {
  tracks$date.uts <- as.numeric(tracks$date.uts)

  tracks <- tracks %>%
    mutate(
      play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"),
      year = format(play_date, "%Y"),
      month = as.numeric(format(play_date, "%m"))
    ) %>%
    filter(!is.na(play_date))

  monthly_data <- tracks %>%
    group_by(year, month) %>%
    summarise(total_tracks = n(), .groups = "drop") %>%
    arrange(year, month) %>%
    mutate(month = factor(month, levels = 1:12, labels = month.abb))

  for (y in unique(monthly_data$year)) {
    p <- ggplot(monthly_data %>% filter(year == y), aes(x = month, y = total_tracks, fill = month)) +
      geom_bar(stat = "identity") +
      labs(title = paste("Monthly Tracks in", y), x = "Month", y = "Total Tracks") +
      theme_minimal() +
      theme(legend.position = "none")
    print(p)
  }

  yearly_data <- tracks %>%
    group_by(year) %>%
    summarise(total_tracks = n(), .groups = "drop") %>%
    arrange(year)

  p2 <- ggplot(yearly_data, aes(x = year, y = total_tracks, fill = year)) +
    geom_bar(stat = "identity") +
    labs(title = "Yearly Tracks Progression", x = "Year", y = "Total Tracks") +
    theme_minimal() +
    theme(legend.position = "none")

  print(p2)
}

getHomeData <- function(tracks, top_n = 5, avg_minutes = 3.5) {

  if (!"minutes" %in% names(tracks)) {
    tracks <- tracks %>% mutate(minutes = avg_minutes)
  }

  tracks <- tracks %>%
    mutate(image_url = str_extract(image, "https://[^\\)\"]+300x300[^\\)\"]+"))

  topArtistsDF <- tracks %>%
    group_by(`artist..text`) %>%
    summarise(
      plays = n(),
      image_url = first(image_url),
      .groups = "drop"
    ) %>%
    arrange(desc(plays)) %>%
    head(top_n)

  total_tracks <- nrow(tracks)

  total_hours <- sum(tracks$minutes) / 60
  listening_hours <- if (total_hours >= 24) {
    days <- floor(total_hours / 24)
    hrs <- round(total_hours %% 24, 1)
    paste(days, "days", hrs, "hrs")
  } else {
    paste(round(total_hours, 1), "hrs")
  }

  top_artist <- if (nrow(topArtistsDF) > 0) topArtistsDF$`artist..text`[1] else NA

  list(
    topArtistsDF = topArtistsDF,
    totalTracks = total_tracks,
    listeningHours = listening_hours,
    topArtist = top_artist
  )
}
