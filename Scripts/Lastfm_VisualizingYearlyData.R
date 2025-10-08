library(dplyr)
library(ggplot2)

# Ensure date.uts is numeric
tracks$date.uts <- as.numeric(tracks$date.uts)

# Convert UNIX timestamps to POSIXct and extract year/month
tracks <- tracks %>%
  mutate(
    play_date = as.POSIXct(date.uts, origin = "1970-01-01", tz = "UTC"), # Convert UNIX timestamp to POSIXct
    year = format(play_date, "%Y"), # Extract year
    month = as.numeric(format(play_date, "%m")) # Extract numeric month
  ) %>%
  filter(!is.na(play_date))  # Remove rows with NA dates

# Summarize monthly tracks
monthly_stats <- tracks %>%
  group_by(year, month) %>%
  summarise(total_tracks = n(), .groups = "drop") %>% # Avoid grouped output warnings
  arrange(year, month)

# Make month a factor for plotting
monthly_stats$month <- factor(monthly_stats$month, levels = 1:12, labels = month.abb)

# Plot each year separately
years <- unique(monthly_stats$year)

for (y in years) {
  data_year <- monthly_stats %>% filter(year == y)
  
  p <- ggplot(data_year, aes(x = month, y = total_tracks, fill = month)) +
    geom_bar(stat = "identity") +
    labs(title = paste("Monthly Tracks in", y),
         x = "Month", y = "Total Tracks") +
    theme_minimal() +
    theme(legend.position = "none")
  
  print(p)
}

# Summarize total tracks per year
yearly_stats <- tracks %>%
  group_by(year) %>%
  summarise(total_tracks = n(), .groups = "drop") %>% # Avoid grouped output warnings
  arrange(year)

# Plot yearly totals
p2 <- ggplot(yearly_stats, aes(x = year, y = total_tracks, fill = year)) +
  geom_bar(stat = "identity") +
  labs(title = "Yearly Tracks Progression",
       x = "Year", y = "Total Tracks") +
  theme_minimal() +
  theme(legend.position = "none")

print(p2)