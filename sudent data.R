student_performance<-read.csv("Student_Performance_Dataset.csv",stringsAsFactors = FALSE)
student_performance
View(student_performance)
class(student_performance)
summary(student_performance)
str(student_performance)
library(dplyr)
library(tidyverse)
library(ggplot2) 


# correlation between attendance percentage,final average score, and study Hours
n_data <- student_performance %>%
  select(Math_Score,English_Score,Science_Score,
         Final_Percentage,Previous_Year_Score,Attendance_Percentage,Study_Hours_Per_Day) 
cor_matrix <- cor(n_data,use="complete.obs")
  View(cor_matrix) 
 HighestStudyStUDENT<-student_performance %>%
   mutate(efficiency=Final_Percentage/Study_Hours_Per_Day)
 
 # Visualizing the lack of correlation between Study Hours and Final Percentage
 ggplot(student_performance, aes(x = Study_Hours_Per_Day, y = Final_Percentage)) +
   geom_jitter(alpha = 0.3, color = "steelblue") + 
   geom_smooth(method = "lm", color = "red") + 
   labs(title = "Study Hours per day vs. Final Academic Performance",
        subtitle = "The flat red line indicates that more hours do not guarantee higher scores",
        x = "Hours Studied",
        y = "Final Percentage (%)") +
   theme_minimal()
 
 
 # Creating the prediction model
 model <- lm(Final_Percentage ~ Math_Score + Science_Score + English_Score, data = student_performance)
 student_performance$Predicted <- predict(model)
 
 # Plotting Actual vs Predicted
 ggplot(student_performance, aes(x = Final_Percentage, y = Predicted)) +
   geom_point(alpha = 0.5, color = "blue") +
   geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
   labs(title = "Model Diagnostic: Actual vs. Predicted Scores",
        subtitle = paste("R-Squared =", round(summary(model)$r.squared, 2)),
        x = "Actual Percentage",
        y = "Predicted Percentage") +
   theme_light()
 
 
 
 #view student who have high grades despite low study Hours
 
 high_efficiency <-  student_performance %>% 
   filter( Study_Hours_Per_Day<3)
 View(high_efficiency)
 # Gender with the highest attendance percentage
 ATtendGend<-student_performance %>%
   group_by(Gender) %>% summarise(attendence= mean(Attendance_Percentage))
 
  ggplot(ATtendGend,aes(x = Gender,y = attendence,fill = Gender)) + geom_bar(stat = "identity",width=0.8) +geom_text((aes(label = attendence,1)),vjust=-0.5)+
    ylim(0,100)+ 
    labs(title = "Gender Vs Attendance PerCent Of Students",x="Attendance (%)",y= "attendance Percentage") + theme_minimal()
# age distribution of student in each class 

  ggplot(student_performance,aes(x=as.factor(Class),fill=factor(Age))) +
   geom_bar(position="dodge")+labs(title=
                                     " Age Distribution of student in each Class",subtitle =
                                     "comparing Students Counts Across Classes 9-12" ,
                                                           x = "Class(Grade)",
                                       y="Number of students", fill = 
                                     "Student age")+ theme_minimal()
 #average Scores by Age and Class
 Score_Summary <-student_performance %>%
   group_by(Class,Age)%>% summarise(Avg_score = mean(Final_Percentage))
ggplot(Score_Summary,aes(x=factor(Class),y=factor(Age),fill = Avg_score)) + geom_tile()+ scale_fill_gradient(low="gray",high = "steelblue")+
  labs(title = "Average Performance by Age And Class",x= "Grade Level",y="Student Age ",fill="Avg Score %")
# Academic Growth Check
student_performance<- student_performance %>%
  mutate(Growth=Final_Percentage - Previous_Year_Score)
#condition that checks if the student improves or Declines
student_performance <- student_performance %>%
  mutate(progress_status = if_else(Growth > 0,"improved","Declined"))
View(student_performance) 

boxplot(Growth~Class, 
        data =student_performance, main="Academic Growth by Class",
        xlab = "Grade level(Class)",
        ylab = "Growth Percent",
        borders="darkblue") 
final_summary <- student_performance %>% 
  group_by(Class)%>% summarise(avg_growth=mean(Growth,na.rm=TRUE))
print(final_summary)