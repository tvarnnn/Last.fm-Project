library(readr)  
library(dplyr)
library(ggplot2)

# Read the CSV file
tracks <- read.csv("../data/all_tracks.csv", stringsAsFactors = FALSE)

# Ensure date.uts is numeric
tracks$date.uts <- as.numeric(tracks$date.uts)

# Convert UNIX timestamps to dates and extract year + month
tracks <- tracks %>%
  mutate(
    play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"), # Convert UNIX timestamps to POSIXct
    year = format(play_date, "%Y"),                                        # Extract year
    month = format(play_date, "%m")                                         # 01 = Jan, 02 = Feb, etc.
  ) %>%
  filter(!is.na(play_date))  # Remove any NA dates

# Tracks per month
monthly_stats <- tracks %>%
  group_by(year, month) %>%
  summarise(total_scrobbles = n(), .groups = "drop") %>% # Count total tracks per month
  arrange(year, month)

# Print monthly stats (show all rows; n = 52 ensures a full year view if 12 months x several years)
print(monthly_stats, n = 52)
