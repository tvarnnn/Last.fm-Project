Last.fm Listening Analysis
Overview

This project analyzes my personal Last.fm listening history using the Last.fm API. It pulls track data, organizes it, and generates insights about my music listening habits over time. The analysis includes yearly and monthly trends, top artists, top tracks, top albums, and listening activity by hour of the day.

Features

Yearly Stats: Total tracks listened per year.

Monthly Stats: Total tracks listened per month, displayed in separate yearly plots.

Top Artists: Pie chart of the top 5 artists with a “Misc” category for all others.

Top Tracks: Table of the top 100 tracks and their play counts.

Top Albums: Table of the top albums based on number of plays.

Listening Trends: Circular bar chart showing listening activity by hour of the day.

Visualizations: Includes bar charts and pie charts to help understand trends at a glance.

Project Structure
Last.fm-Analysis/
│
│- Main/
│  │- main.R                 # Main script to run all analysis
│  
│
│- Scripts/
│  │- Lastfm_Yearly.R
│  │- Lastfm_Monthly.R
│  │- Lastfm_TopArtists.R
│  │- Lastfm_TopTracks.R
│  │- Lastfm_TopAlbums.R
│  │- Lastfm_ListeningTrends.R
│  │- Lastfm_VisualizingYearlyData.R
│
|
|
│- data/
│     │-all_tracks.csv      # CSV file containing track history
|
|
|
│- Misc/
   │- .gitignore
   │- .RData
   │- .Rhistory

Setup & Usage

Clone the repository:

git clone https://github.com/tvarnnn/Last.fm-Analysis.git
cd Last.fm-Analysis/Main


Install required R packages

install.packages(c("httr", "jsonlite", "dplyr", "ggplot2", "readr"))


Set your Last.fm username and API key in main.R:

user <- "YOUR_LASTFM_USERNAME"
api_key <- "YOUR_LASTFM_API_KEY"


Run the analysis:

source("main.R")


This will fetch data (or read existing CSV), run all analysis scripts, and generate plots and tables.

Notes

The project is modular: each analysis is in a separate script.

The folder structure keeps scripts, data, and miscellaneous files organized.

The visualizations are designed to be easy to read and interpretable at a glance.

Future improvements may include a front-end dashboard for interactive viewing.
