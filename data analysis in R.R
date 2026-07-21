#R CAPSTONE 
#*EXPLORING DATA, do an exploratory, diagnostics and descriptive analytics on the data 
#*correct all inconsistencies with the dates
#*carry out a univariate analysis on the variable disease type(show summary)
#*perform a bivariate analysis(correlation) on the variables Disease type and reported cases, visualize using a scatter plot 
#*create a new variable(column) by adding it to the dataset using  Date of report, variables should be 1. year of date of report, 2. Month of date of report 
#*determine the  distribution of Age, if its a normal distribution report correctly mean and standard deviation, if its not report median and IQR. and visualize your distribution using a histogram chart on R. report center and spread as appropriate. report five number summary and visualize using a boxplot 
#* factor gender and report the mean of age by group summaries of the gender 
# Report the proportions of the Gender(male and female)
# Report correctly the prevalence of disease type(covid 19) by reported cases and confirmed cases 
# carry out a bivariate analysis for variables confirmed cases and reported cases
# report corrected the sum of reported cases, mortality, confirmed cases and recoveries 
# report frequencies of disease type and their proportions and visualize using bar chats 
# report and visualize the trend/pattern for reported cases and confirmed cases by Date of report.
#Note this capstone is not limited to the above questions you can do more based on your initiative. work according to your strength, should be submitted in a zip file(data,R code and capstone(charts and so on). to be submitted and presented on or before  20th June 2025

R_capstone <- read.csv("IDSS2.csv",stringsAsFactors =  FALSE)
View(R_capstone)
str(R_capstone) 

library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

summary(R_capstone)
colnames(R_capstone) 


#corrected inconsistency in the dates 
R_capstone$Date.of.Report <- as.Date(R_capstone$Date.of.Report, format = "%d-%b-%y")
str(R_capstone$Date.of.Report)

#univariate analysis carried out
R_capstone %>%
  count(Disease.Type)
summary(Disease.Type)

ggplot(R_capstone, aes(x = Disease.Type, fill =disease_colour )) +
  geom_bar() +
  labs(
    title = "Distribution of Disease Types",
    x = "Disease Type",
    y = "Count"
  ) +
  theme_minimal()

#bivariate analysis of disease type and reported cases
#R_capstone$Disease.Type<-as.factor(R_capstone$Disease.Type)
#there is no correlation for this the disease type is a categorical variable

#creating a new column
R_capstone<- R_capstone %>%
  mutate(year= format(R_capstone$Date.of.Report,"%Y"),
  months=format(R_capstone$Date.of.Report,"%m"))

str(R_capstone$Age)

View(R_capstone)

#determine the distribution of age
qqnorm(R_capstone$Age) # not normal although it has outlier at extreme end that is heavy tail it is also called a leptokurtoic distribution
median(R_capstone$Age)# 39
IQR(R_capstone$Age) # 13

age_colour <- c(rep("lightblue",7))
age_colour[6] <- "lightcoral"

#histogram plot of age distribution
hist(R_capstone$Age,
       main = "Age Distribution of patients",
     xlab = "Age",
     col = age_colour,
     borders = "red")

summary(R_capstone$Age)
str(R_capstone$age)


#factor gender and report the mean of age by group summaries of the gender 
gend<-factor(R_capstone$Gender)

R_capstone %>%
  group_by(Gender) %>% summarise(avgAge = mean(Age,na.rm=TRUE))

# the proportions of the Gender(male and female) 

gend_count <- table(R_capstone$Gender)
prop_Male_Female <- prop.table(gend_count)

prop_df <- data.frame(
  Gender = names(prop_Male_Female),
  Proportion = as.numeric(prop_Male_Female)
)

ggplot(prop_df, aes(x = Gender, y = Proportion, fill = Gender)) +
  geom_bar(stat = "identity", width = 0.3) +
  
  # LABELS ON TOP OF BARS
  geom_text(aes(label = scales::percent(Proportion)),
            vjust = -0.5, size = 5) +
  
  labs(title = "Male and Female Proportion",
       x = "Gender",
       y = "Proportion") +
  
  scale_y_continuous(labels = scales::percent) +
  ylim(0, 0.55)


# Report correctly the prevalence of disease type(covid 19) by reported cases and confirmed cases 
total_reported <- sum(R_capstone$Reported.Cases, na.rm = TRUE)
total_confirmed <- sum(R_capstone$Confirmed.Cases, na.rm = TRUE)
covid_case <- subset(R_capstone,Disease.Type =="COVID-19")

covid_reported <- sum(R_capstone$Reported.Cases[R_capstone$Disease.Type == "COVID-19"], na.rm = TRUE)
covid_confirmed <- sum(R_capstone$Confirmed.Cases[R_capstone$Disease.Type == "COVID-19"], na.rm = TRUE)

View(covid_case)
percentage_reportedCase <- (covid_reported/total_reported)*100
percentage_by_confirmed <- (covid_confirmed/total_confirmed)*100

# carry out for bivariant analysis for confirmed cases and reported cases
analysis <- lm(R_capstone$Reported.Cases~ R_capstone$Confirmed.Cases)



# report corrected the sum of reported cases, mortality, confirmed cases and recoveries 
infection_mortality <- as.numeric(gsub("%"," ",R_capstone$Infectious.Mortality.Rate....))
  sum(R_capstone$Reported.Cases+infection_mortality+R_capstone$Recovered.Cases)
   
  #report frequencies of disease type and their proportions and visualize using bar chats

 frequenciesOfDiseases <- prop.table(frequencies)
 
 frequencies_sorted <- sort(frequenciesOfDiseases, decreasing = FALSE)
 
 disease_colour <- rep("lightblue", length(frequencies_sorted))
 disease_colour[3] <- "lightcoral"   # optional highlight
 
 diseaseBarplot <- barplot(
   frequencies_sorted,
   main = "PROPORTION FREQUENCIES OF DISEASE",
   col = disease_colour,
   las = 2
 )
 
# Add text labels
 text(
   x = diseaseBarplot,
   y = frequencies_sorted + 0.02,     # move label above bar
   labels = round(frequencies_sorted, 3),
   cex = 1.2
 )
 
 #report and visualize the trend/pattern for reported cases and confirmed cases by Date of report. 
 
 cor(R_capstone$Reported.Cases,R_capstone$Confirmed.Cases)
 summary(R_capstone$Reported.Cases)
 summary(R_capstone$Confirmed.Cases)
 str(R_capstone$Confirmed.Cases)

 R_capstone_summary <- R_capstone %>%
  group_by(year, Disease.Type) %>%
  summarise(
    average_reported_cases = mean(Reported.Cases, na.rm = TRUE),
    average_confirmed_cases = mean(Confirmed.Cases, na.rm = TRUE),
    .groups = "drop"
  )
 
 # Line chart
 ggplot(R_capstone_summary, aes(x = year)) +
   geom_line(aes(y = average_reported_cases, color = "Reported Cases", group = Disease.Type), size = 1.2) +
   geom_line(aes(y = average_confirmed_cases, color = "Confirmed Cases", group = Disease.Type), size = 1.2) +
   geom_point(aes(y = average_reported_cases, color = "Reported Cases"), size = 2) +
   geom_point(aes(y = average_confirmed_cases, color = "Confirmed Cases"), size = 2) +
   facet_wrap(~ Disease.Type) +   # creates a separate panel per disease
   labs(
     title = "Yearly Average of Reported and Confirmed Cases by Date of report",
     x = "year",
     y = "Average Number of Cases",
     color = "Case Type"
   ) +
   theme_minimal() +
   theme(axis.text.x = element_text(angle = 45, hjust = 1))
 
 #Country with the highest recovery rate
 # Remove % if any and convert to numeric
 Recovery<- as.numeric(gsub("%", "", R_capstone$Recovery.Rate....))
 
 # Aggregate recovery rate by state (mean if multiple entries per state)
 state_recovery <-R_capstone %>%
   group_by(Location..State.) %>%
   summarise(mean_recovery = mean(Recovery.Rate...., na.rm = TRUE))
 
 # Find the state with the highest recovery rate
 highest_state <- state_recovery %>% filter(mean_recovery == max(mean_recovery))
 
 stateColour <- c(rep("lightblue",10))
 stateColour [6] <- "lightcoral"
 # Plot bar chart 
 ggplot(state_recovery, aes(x = reorder(Location..State., -mean_recovery), y = mean_recovery)) +
   geom_bar(stat = "identity", fill =stateColour) +
  geom_text(aes(label = paste0(round(mean_recovery, 1), "%")), 
            vjust = -0.5, size = 3.5) +
   labs(title = "State vs Recovery Rate",
        x = "State",
        y = "Recovery Rate (%)") +
   theme(axis.text.x = element_text(angle = 45, hjust = 1))
 
 
 
 # what is the average period of incubation for malaria
 R_capstone %>%
   filter(Disease.Type == "Malaria") %>%
   summarise(average_malaria = mean(Incubation.Period..Days., na.rm = TRUE))
 
 # what is the average period of incubation for tubercluosis
 # what is the average period of incubation for cholera
 #  what is the average period of incubation for covid_19
 # what is the average period of incubation for typhoid
 # Calculate the average period of incubation for all diseases simultaneously
 incubation_summary <- R_capstone %>%
   group_by(Disease.Type) %>%
   summarise(
     average_incubation = mean(Incubation.Period..Days., na.rm = TRUE)
   )
 
 
 
 # disease with THE highest recovery Rate
 HIGhtest <- R_capstone %>%
   group_by(Disease.Type) %>%
   summarise(
     Average_Recovery_Rate = mean(Recovery.Rate, na.rm = TRUE)
   )
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
