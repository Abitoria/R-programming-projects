#load packages
require(tidyverse)
require(dplyr)
require(janitor)
require(skimr)
require(ggplot2)
require(shiny)
require(shinydashboard)
require(scales)
require(readr)


movie_IMDB <- read_csv("messy_IMDB_dataset-selected-columns_movie_dataset.csv")



clean_movies<- clean_names(movie_IMDB )
clean_movies
glimpse(clean_movies)

colSums(is.na(clean_movies))
summary(clean_movies)
View(clean_movies)

#Remove totally empty rows and columns like the x9
clean_movies <- clean_movies |>
  select(-any_of("x9")) |>
  remove_empty(which = c("rows", "cols"))
glimpse(clean_movies)

colSums(is.na(clean_movies))


clean_movies <- clean_movies %>%
  
  # 1. Safely drop x9 and clear out any other 100% empty columns/rows
  select(-any_of("x9")) %>%
  remove_empty(which = c("rows", "cols")) %>%
  
  # 2. THE GLOBAL SWEEP: Convert all text null variations to true NAs everywhere
  mutate(across(everything(), ~ na_if(.x, "NULL"))) %>%
  mutate(across(everything(), ~ na_if(.x, "null"))) %>%
  mutate(across(everything(), ~ na_if(.x, "NaN"))) %>%
  mutate(across(everything(), ~ na_if(.x, "Nan"))) %>%
  mutate(across(everything(), ~ na_if(.x, "nan"))) %>%
  mutate(across(everything(), ~ na_if(.x, "#N/A"))) %>%
  mutate(across(everything(), ~ na_if(.x, "not applicable"))) %>%
  mutate(across(everything(), ~ na_if(.x, "Not Applicable"))) %>%
  mutate(across(everything(), ~ na_if(.x, "-"))) %>%
  mutate(across(everything(), ~ na_if(.x, "inf"))) %>%

  mutate(duration = as.numeric(duration)) %>%
  
  mutate(
    income_clean = str_replace_all(income, "[\\$\\s,]", ""),
    income_numeric = as.numeric(income_clean)
  )

clean_movies <- clean_movies |>
  mutate(
    duration_clean = str_extract(duration, "^[0-9]+"),  
    duration = as.numeric(duration_clean)
  )

# confirm no more Inf or non-numeric junk
sum(is.infinite(clean_movies$duration))
sum(is.na(clean_movies$duration))
class(clean_movies$duration)

genre_long <- clean_movies |>
  separate_rows(genr, sep = ",\\s*")

# count movies per genre
genre_counts <- genre_long |>
  filter(!is.na(genr)) |>
  count(genr, sort = TRUE)

genre_counts

# bar chart, sorted highest to lowest
genre_counts <- genre_long |>
  filter(!is.na(genr)) |>
  count(genr, sort = TRUE) |>
  mutate(genre = fct_reorder(genr, n))   # order factor levels by count

genre_counts <- genre_long |>
  filter(!is.na(genr)) |>
  count(genr, sort = TRUE) |>
  mutate(genre = fct_reorder(genr, n))   # orders bars by count

ggplot(genre_counts, aes(x = genre, y = n, fill = genre)) +
  geom_col(alpha = 0.85) +
  geom_text(aes(label = n), hjust = -0.2, size = 3.5) +
  coord_flip() +
  labs(
    title = "Number of Movies by Genre",
    x = NULL,
    y = "Number of Movies"
  ) +
  theme_classic() +
  theme(legend.position = "none")


View(clean_movies)
#group by content rating,summarize by mean income rating(what genre as the highest rating)
View(genre_rating_summary <-clean_movies %>%
  group_by(content_rating) %>%
  summarise(avg_income_rating = round(mean(income_numeric, na.rm = TRUE))) %>%
  arrange(avg_income_rating))
#column plot
(h<-ggplot(genre_rating_summary, aes(x=content_rating, y = avg_income_rating, fill = content_rating)) +
  geom_col(alpha = 0.8) +
  labs(
    title = "Average Movie Income by Content Rating",
    x = "Content Rating",
    y = "Average Box Office Income ($)"
  ) +geom_text(aes(label=avg_income_rating),vjust=-0.2,size =5.0) +
  theme_classic())
h + scale_x_discrete(limits=c("Not Rated","Approved","R","PG","G","PG-13"))




#correct the date format
clean_movies <- clean_movies |>
  mutate(
    release_year_prepped = release_year |>
      str_replace_all(regex("(\\d+)(st|nd|rd|th)", ignore_case = TRUE), "\\1") |>
      str_replace_all(regex("\\bof\\b", ignore_case = TRUE), "") |>
      str_squish(),
    release_date_clean = parse_date_time(
      release_year_prepped,
      orders = c("ymd", "mdy", "dmy", "dby", "ybd", "dBy", "Bdy"),
      quiet = TRUE
    ),
    release_year_clean = year(release_date_clean),
    year_fallback = str_extract(release_year, "\\b(19|20)\\d{2}\\b"),
    release_year_clean = coalesce(release_year_clean, as.numeric(year_fallback))
  )
#number of movies per decade

movies_per_decade <- clean_movies |>
  filter(!is.na(release_year_clean)) |>
  mutate(decade = paste0(floor(release_year_clean / 10) * 10, "s")) |>
  count(decade, sort = FALSE) |>
  mutate(decade = fct_reorder(decade, n, .desc = TRUE))

#visualize using bar plot
ggplot(movies_per_decade, aes(x = decade, y = n, fill = decade)) +
  geom_col(alpha = 0.85) +
  geom_text(aes(label = n), vjust = -0.3, size = 3.5) +
  labs(title = "Number of Movies per Decade", x = "Decade", y = "Number of Movies") +
  theme_classic() +
  theme(legend.position = "none")

#top 10 highest grossing movies
top_10_movies <- clean_movies |>
  filter(!is.na(income_numeric)) |>
  slice_max(income_numeric, n = 10) |>
  mutate(original_titl = fct_reorder(original_titl, income_numeric))

ggplot(top_10_movies, aes(x = original_titl, y = income_numeric, fill = original_titl)) +
  geom_col(alpha = 0.85) +
  geom_text(aes(label = scales::dollar(income_numeric)), hjust = -0.05, size = 3) +
  coord_flip() +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Top 10 Highest-Grossing Movies", x = NULL, y = "Box Office Income") +
  theme_classic() +
  theme(legend.position = "none")




# Total movies analyzed
total_movies <- nrow(clean_movies)

# Average box office income
avg_income <- clean_movies |>
  summarise(avg = mean(income_numeric, na.rm = TRUE)) |>
  pull(avg)

# Top genre by volume
top_genre <- genre_long |>
  filter(!is.na(genr)) |>
  count(genr, sort = TRUE) |>
  slice_max(n, n = 1) |>
  pull(genr)

genre_income <- genre_long |>
  filter(!is.na(genr), !is.na(income_numeric)) |>
  group_by(genr) |>
  summarise(avg_income = mean(income_numeric, na.rm = TRUE)) |>
  arrange(avg_income) |>
  mutate(genre = fct_reorder(genr, avg_income))

# Average duration
avg_duration <- clean_movies |>
  summarise(avg = mean(duration, na.rm = TRUE)) |>
  pull(avg)

# quick check these all look right
total_movies
avg_income
top_genre
avg_duration



ui <- dashboardPage(
  dashboardHeader(title = "Movie Analytics Dashboard"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      valueBox(total_movies, "Total Movies Analyzed", icon = icon("film"), color = "blue"),
      valueBox(scales::dollar(round(avg_income)), "Average Box Office Income", icon = icon("dollar-sign"), color = "green"),
      valueBox(top_genre, "Most Common Genre", icon = icon("star"), color = "yellow"),
      valueBox(paste0(round(avg_duration), " min"), "Average Duration", icon = icon("clock"), color = "purple")
    ),
    fluidRow(
      box(title = "Average Income by Content Rating", width = 6, plotOutput("chart_rating_income")),
      box(title = "Runtime vs. Box Office Income", width = 6, plotOutput("chart_duration_income"))
    ),
    fluidRow(
      box(title = "Number of Movies per Decade", width = 6, plotOutput("chart_decade")),
      box(title = "Number of Movies by Genre", width = 6, plotOutput("chart_genre_count"))
    ),
    fluidRow(
      box(title = "Average Income by Genre", width = 6, plotOutput("chart_genre_income")),
      box(title = "Top 10 Highest-Grossing Movies", width = 6, plotOutput("chart_top10"))
    )
  )
)

#### 7. SERVER ###################################################################
server <- function(input, output) {
  
  output$chart_rating_income <- renderPlot({
    ggplot(genre_rating_summary, aes(x = content_rating, y = avg_income_rating, fill = content_rating)) +
      geom_col(alpha = 0.8) +
      geom_text(aes(label = scales::dollar(round(avg_income_rating))), vjust = -0.2, size = 3.0) +
      scale_x_discrete(limits = c("Not Rated", "Approved", "R", "PG", "G", "PG-13")) +
      labs(x = "Content Rating", y = "Average Box Office Income ($)") +
      theme_classic() +
      theme(legend.position = "none")
  })
  output$chart_duration_income <- renderPlot({
    ggplot(clean_movies, aes(x = duration, y = income_numeric)) +
      geom_point(color = "midnightblue", alpha = 0.6, size = 3) +
      geom_smooth(method = "lm", color = "red", se = FALSE, linetype = "dashed") +
      scale_y_continuous(labels = scales::dollar) +
      labs(x = "Duration (Minutes)", y = "Box Office Income") +
      theme_classic()
  })
  
  output$chart_decade <- renderPlot({
    ggplot(movies_per_decade, aes(x = decade, y = n, fill = decade)) +
      geom_col(alpha = 0.85) +
      geom_text(aes(label = n), vjust = -0.3, size = 3.5) +
      labs(x = "Decade", y = "Number of Movies") +
      theme_classic() +
      theme(legend.position = "none")
    
  })
  output$chart_genre_income <- renderPlot({
    ggplot(genre_income, aes(x = genre, y = avg_income, fill = genre)) +
      geom_col(alpha = 0.85) +
      geom_text(aes(label = scales::dollar(round(avg_income))), hjust = -0.1, size = 3) +
      coord_flip() +
      scale_y_continuous(labels = scales::dollar, expand = expansion(mult = c(0, 0.15))) +
      labs(x = NULL, y = "Average Income") +
      theme_classic() +
      theme(legend.position = "none")
  })

      output$chart_genre_count <- renderPlot({
        ggplot(genre_counts, aes(x = genre, y = n, fill = genre)) +
          geom_col(alpha = 0.85) +
          geom_text(aes(label = n), hjust = -0.2, size = 3.5) +
          coord_flip() +
          labs(
            title = "Number of Movies by Genre",
            x = NULL,
            y = "Number of Movies"
          ) +
          theme_classic() +
          theme(legend.position = "none")
      })
      
      output$chart_top10 <- renderPlot({
        ggplot(top_10_movies, aes(x = original_titl, y = income_numeric, fill = original_titl)) +
          geom_col(alpha = 0.85) +
          geom_text(aes(label = scales::dollar(income_numeric)), hjust = -0.05, size = 3) +
          coord_flip() +
          scale_y_continuous(labels = scales::dollar, expand = expansion(mult = c(0, 0.15))) +
          labs(x = NULL, y = "Box Office Income") +
          theme_classic() +
          theme(legend.position = "none")
      })
}

#### 8. RUN APP ###################################################################
shinyApp(ui, server)





