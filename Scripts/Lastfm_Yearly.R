library(readr)  
library(dplyr)  
library(ggplot2)

# Read the CSV file
tracks <- read.csv("../data/all_tracks.csv", stringsAsFactors = FALSE)

# Ensure date.uts is numeric
tracks$date.uts <- as.numeric(tracks$date.uts)

# Convert UNIX timestamps to dates and extract year
tracks <- tracks %>%
  mutate(
    play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"), # Convert UNIX timestamps to POSIXct
    year = format(play_date, "%Y") # Extract year
  ) %>%
  filter(!is.na(play_date)) # Remove NA dates

# Tracks per year
yearly_stats <- tracks %>%
  group_by(year) %>%
  summarise(total_tracks = n()) %>% # Count total tracks per year
  arrange(year)

# Print yearly stats
print(yearly_stats)