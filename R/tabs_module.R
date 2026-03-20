library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(plotly)

# ── Artists Tab ───────────────────────────────────────────────────────────────

artistsUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Top 5 Artists by Plays", width = 5,
        solidHeader = TRUE, status = "primary",
        plotOutput(ns("artists_chart"), height = "500px")
      ),
      box(
        title = "All Artists", width = 7,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("artists_table"))
      )
    ),
    fluidRow(
      box(
        title = "Artist Discovery Timeline", width = 12,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("discovery_table"))
      )
    )
  )
}

artistsServer <- function(id, all_tracks) {
  moduleServer(id, function(input, output, session) {

    artists_data <- all_tracks %>%
      group_by(`artist..text`) %>%
      summarise(Plays = n(), .groups = "drop") %>%
      arrange(desc(Plays)) %>%
      rename(Artist = `artist..text`)

    output$artists_chart <- renderPlot({
      top5 <- head(artists_data, 5)
      misc_count <- sum(artists_data$Plays) - sum(top5$Plays)
      top5 <- rbind(top5, data.frame(Artist = "Misc", Plays = misc_count))
      top5 <- top5 %>%
        mutate(legend_label = paste0(Artist, " (", round(100 * Plays / sum(Plays), 1), "%)"))

      ggplot(top5, aes(x = "", y = Plays, fill = legend_label)) +
        geom_bar(stat = "identity", width = 1) +
        coord_polar("y", start = 0) +
        theme_void() +
        theme(legend.title = element_blank(), legend.text = element_text(size = 13))
    })

    output$artists_table <- DT::renderDataTable({
      DT::datatable(artists_data, options = list(pageLength = 10), rownames = FALSE)
    })

    output$discovery_table <- DT::renderDataTable({
      data <- all_tracks %>%
        group_by(`artist..text`) %>%
        summarise(
          Discovered = as.Date(min(play_date)),
          Plays = n(),
          .groups = "drop"
        ) %>%
        arrange(desc(Discovered)) %>%
        rename(Artist = `artist..text`)

      DT::datatable(data, options = list(pageLength = 10), rownames = FALSE)
    })

  })
}

# ── Albums Tab ────────────────────────────────────────────────────────────────

albumsUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Top Albums", width = 12,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("albums_table"))
      )
    )
  )
}

albumsServer <- function(id, all_tracks) {
  moduleServer(id, function(input, output, session) {

    albums_data <- all_tracks %>%
      group_by(`artist..text`, `album..text`) %>%
      summarise("Play Count" = n(), .groups = "drop") %>%
      arrange(desc(`Play Count`)) %>%
      rename(Artist = `artist..text`, Album = `album..text`)

    output$albums_table <- DT::renderDataTable({
      DT::datatable(albums_data, options = list(pageLength = 10), rownames = FALSE)
    })

  })
}

# ── Tracks Tab ────────────────────────────────────────────────────────────────

tracksUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      box(
        title = "Top Tracks", width = 12,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("tracks_table"))
      )
    )
  )
}

tracksServer <- function(id, all_tracks) {
  moduleServer(id, function(input, output, session) {

    tracks_data <- all_tracks %>%
      group_by(name, `artist..text`) %>%
      summarize("Play Count" = n(), .groups = "drop") %>%
      arrange(desc(`Play Count`)) %>%
      rename(Track = name, Artist = `artist..text`)

    output$tracks_table <- DT::renderDataTable({
      DT::datatable(tracks_data, options = list(pageLength = 10), rownames = FALSE)
    })

  })
}

# ── History Tab ───────────────────────────────────────────────────────────────

historyUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$head(tags$script(HTML(
      "$(document).on('shiny:value', function(e) {
        if ($(e.target).hasClass('datatables')) {
          var pos = $(window).scrollTop();
          setTimeout(function() { $(window).scrollTop(pos); }, 10);
        }
      });"
    ))),
    fluidRow(
      box(
        width = 12,
        solidHeader = TRUE, status = "primary",
        column(4, selectInput(ns("year_select"), "Select a Year:", choices = NULL, width = "200px")),
        column(8, br(), uiOutput(ns("filter_label")))
      )
    ),
    fluidRow(
      box(
        title = "Monthly Scrobbles — click a bar to filter, click again to reset",
        width = 12, solidHeader = TRUE, status = "primary",
        plotlyOutput(ns("monthly_chart"))
      )
    ),
    fluidRow(
      box(
        title = "Top Artists", width = 4,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("top_artists"))
      ),
      box(
        title = "Top Albums", width = 4,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("top_albums"))
      ),
      box(
        title = "Top Tracks", width = 4,
        solidHeader = TRUE, status = "primary",
        DT::dataTableOutput(ns("top_tracks"))
      )
    )
  )
}

historyServer <- function(id, all_tracks) {
  moduleServer(id, function(input, output, session) {

    observe({
      updateSelectInput(session, "year_select",
        choices = sort(unique(all_tracks$year), decreasing = TRUE)
      )
    })

    year_data <- reactive({
      req(input$year_select)
      all_tracks %>% filter(year == input$year_select)
    })

    # Track selected month — NULL means full year view
    selected_month <- reactiveVal(NULL)

    # Reset selected month when year changes
    observeEvent(input$year_select, { selected_month(NULL) })

    # Handle bar clicks — click same bar again to deselect
    observeEvent(event_data("plotly_click", source = "history_monthly"), {
      click <- event_data("plotly_click", source = "history_monthly")
      clicked <- click$x
      if (!is.null(selected_month()) && selected_month() == clicked) {
        selected_month(NULL)
      } else {
        selected_month(clicked)
      }
    })

    # Label showing current filter state
    output$filter_label <- renderUI({
      if (is.null(selected_month())) {
        tags$p(paste("Viewing all of", input$year_select), style = "color: #888; margin-top: 6px;")
      } else {
        tags$p(paste("Viewing", selected_month(), input$year_select, "— click the bar again to reset"),
               style = "color: #e74c3c; margin-top: 6px;")
      }
    })

    output$monthly_chart <- renderPlotly({
      data <- data.frame(month_num = 1:12, month_label = month.abb) %>%
        left_join(
          year_data() %>% group_by(month) %>% summarise(scrobbles = n(), .groups = "drop"),
          by = c("month_num" = "month")
        ) %>%
        mutate(scrobbles = ifelse(is.na(scrobbles), 0, scrobbles))

      bar_colors <- ifelse(
        !is.null(selected_month()) & data$month_label == selected_month(),
        "#e74c3c", "#3c8dbc"
      )

      plot_ly(
        data,
        x = ~factor(month_label, levels = month.abb),
        y = ~scrobbles,
        type = "bar",
        marker = list(color = bar_colors),
        source = "history_monthly",
        hovertemplate = "%{x}: %{y} scrobbles<extra></extra>"
      ) %>%
        layout(
          xaxis = list(title = ""),
          yaxis = list(title = "Scrobbles"),
          showlegend = FALSE
        ) %>%
        event_register("plotly_click")
    })

    # Data filtered by selected month (or full year if none selected)
    table_data <- reactive({
      data <- year_data()
      sm <- selected_month()
      if (!is.null(sm)) {
        data <- data %>% filter(month == which(month.abb == sm))
      }
      data
    })

    output$top_artists <- DT::renderDataTable({
      data <- table_data() %>%
        group_by(`artist..text`) %>%
        summarise(Plays = n(), .groups = "drop") %>%
        arrange(desc(Plays)) %>%
        rename(Artist = `artist..text`)

      DT::datatable(data, options = list(pageLength = 10, dom = "tp"), rownames = FALSE)
    })

    output$top_albums <- DT::renderDataTable({
      data <- table_data() %>%
        group_by(`artist..text`, `album..text`) %>%
        summarise(Plays = n(), .groups = "drop") %>%
        arrange(desc(Plays)) %>%
        rename(Artist = `artist..text`, Album = `album..text`)

      DT::datatable(data, options = list(pageLength = 10, dom = "tp"), rownames = FALSE)
    })

    output$top_tracks <- DT::renderDataTable({
      data <- table_data() %>%
        group_by(name, `artist..text`) %>%
        summarise(Plays = n(), .groups = "drop") %>%
        arrange(desc(Plays)) %>%
        rename(Track = name, Artist = `artist..text`)

      DT::datatable(data, options = list(pageLength = 10, dom = "tp"), rownames = FALSE)
    })

  })
}
