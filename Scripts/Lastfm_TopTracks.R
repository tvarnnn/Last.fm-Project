library(dplyr)

# Read CSV 
tracks <- read.csv("../data/all_tracks.csv", stringsAsFactors = FALSE)

# Count tracks
track_counts <- tracks %>%
  group_by(name) %>%
  summarize(total_scrobbles = n()) %>%
  arrange(desc(total_scrobbles)) %>%
  rename(
    Track = name,
    "Play count" = total_scrobbles
  )

# Get top 100 tracks 
top_tracks <- head(track_counts, 100)

# Print in a table
print(top_tracks)

View(top_tracks)