# Last.fm Listening Analysis

A personal Shiny dashboard that pulls your Last.fm scrobble history and lets you explore your music listening habits interactively.

## Features

- **Home** — total scrobbles, top artist, listening hours, current & longest listening streaks, top 5 artist cards, listening clock (dead zones vs peak hours visualized), and top 15 tracks
- **Artists** — pie chart of top 5 artists, full ranked table, and artist discovery timeline showing when you first scrobbled each artist
- **Albums** — full ranked table of top albums
- **Tracks** — full ranked table of top tracks
- **History** — pick a year to see the monthly scrobble chart, click any bar to drill into that month's top artists, albums, and tracks

## Project Structure

```
Last.fm-Project/
├── app.R             # Shiny dashboard entry point
├── fetch_data.R      # Standalone script to fetch & run analysis from console
├── R/
│   ├── analysis.R    # All analysis functions
│   ├── home_module.R # Home tab UI + server
│   └── tabs_module.R # Artists, Albums, Tracks, History tab UI + server
├── data/
│   └── all_tracks.csv  # Generated on first run — gitignored
├── .Renviron           # API credentials — gitignored
└── Last.fm Tracking.Rproj
```

## Setup

**1. Clone the repo and open the project**
```
git clone https://github.com/tvarnnn/Last.fm-Analysis.git
```
Open `Last.fm Tracking.Rproj` in RStudio.

**2. Install dependencies**
```r
install.packages(c("shiny", "shinydashboard", "httr", "jsonlite", "dplyr",
                   "ggplot2", "stringr", "here", "DT", "plotly"))
```

**3. Add your credentials**

Create a `.Renviron` file at the project root:
```
LASTFM_USER=your_username
LASTFM_API_KEY=your_api_key
```
Get a free API key at [last.fm/api](https://www.last.fm/api). Restart R after saving.

**4. Run the app**

Open `app.R` and click **Run App**. On first launch it will automatically fetch your full scrobble history and save it to `data/all_tracks.csv`. Subsequent launches load straight from the CSV.

To refresh your data with new scrobbles, click the **Refresh Data** button in the sidebar.

## Notes

- Built for personal use with a single Last.fm account
- Data is fetched once and cached locally — no repeated API calls
- `.Renviron` and `data/` are both gitignored so credentials and personal data never get committed
