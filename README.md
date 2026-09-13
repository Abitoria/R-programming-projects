#  R Programming & Statistical Analysis Portfolio

**Analyst:** Olawoyin Olufunmilayo Esther

## Overview
This repository contains advanced statistical data analyses and exploratory programming projects built using **R** (`tidyverse`, `ggplot2`), focusing on public health epidemiology and educational data mining.

---

##  Project 1: Disease Outbreak Exploratory & Diagnostic Analysis (IDSS2 Capstone)
* **Tools:** R, ggplot2, Descriptive & Diagnostic Statistics
* **Objective:** Analyze 500 observations across 15 variables tracking multi-state disease outbreaks (Malaria, COVID-19, Cholera, Tuberculosis, and Typhoid) to evaluate spread, recovery rates, and severity.
* **Key Findings:**
  * **Prevalence & Demographics:** Malaria and Typhoid showed the highest proportion frequencies (~22% and ~20.6%), with a near-even gender split (51% male, 49% female). COVID-19 accounted for 19.9% of reported cases.
  * **Geographic Disparities:** Recovery rates varied drastically across states, ranging from a high of 68.3% in Kano down to 52.3% in Lagos, highlighting potential healthcare delivery gaps.
  * **Clinical Metrics:** Average incubation periods mapped closely across illnesses, ranging from 10.18 days (COVID-19) to 11.49 days (Typhoid).

---

## 🎓 Project 2: Decoding Student Success Statistical Analysis
* **Tools:** R, Tidyverse, ggplot2, Multiple Linear Regression.
* **Objective:** Analyzed a 5,000-student dataset to test whether environmental and lifestyle factors impact academic performance, or if success is driven strictly by core subject mastery.
* **Key Findings:**
  * **Disproving External Assumptions:** Proved that internet access (94.6% vs 94.8% pass rate), student age, and study hours have virtually zero correlation with final grades ($r = -0.013$ for study ho.
  * **Data Leakage Resolution:** Identified and corrected a data leakage issue in initial multiple linear regression models ($R^2 = 1.0$), proving that final percentages are mathematically calculated from subject scores rather than external behavior.
  * **Core Insight:** True academic success is strictly governed by core subject mastery (Math, English, Science) rather than lifestyle metrics.
