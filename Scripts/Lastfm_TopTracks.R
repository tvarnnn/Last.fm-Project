library(dplyr)

# Read CSV 
tracks <- read.csv("../data/all_tracks.csv", stringsAsFactors = FALSE)

# Count tracks grouped by track + artist
track_counts <- tracks %>%
  group_by(name, artist..text) %>%
  summarize(total_scrobbles = n(), .groups = "drop") %>%
  arrange(desc(total_scrobbles)) %>%
  rename(
    Track = name,
    Artist = artist..text,
    "Play count" = total_scrobbles
  )

# Get top 100 tracks 
top_tracks <- head(track_counts, 100)

# Print in a table
print(top_tracks)


