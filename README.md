# Student Performance Project
> *Uses student data to compare several quantitative and qualitative factors that create a successful student.*

---

## ⚙️ Concepts Used


- [X] Exploratory Data Analysis (EDA)
- [X] SQL Analysis / Querying
- [X] Dashboard / Data Visualization
- [ ] Data Pipeline / ETL
- [ ] Predictive Modelling / Machine Learning
- [X] Data Cleaning / Wrangling
- [X] End-to-End (multiple of the above)
- [ ] Other: ___________

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Objectives](#2-objectives)
3. [Project Tools](#3-project-tools)
4. [Repository Structure](#4-repository-structure)
5. [Data Workflow](#5-data-workflow)
6. [Data Model & Schema](#6-data-model--schema)
7. [Insights/Recommendations](#7-insightsrecommendations)
8. [Assumptions, Limitations, & Enhancements](#8-limitations--enhancements)
9. [Deliverables](#9-deliverables)
10. [Author](#10-author)

---

## 1. Project Overview

I searched for a free online dataset on Kaggle that provided opportunities for both data cleaning and for EDA. Student performance is an interesting thing to try to measure, as there are so many factors that go into creating academic success.

My essential question became, what factors determine student success?

I cleaned the data thoroughly in MySQl. See the Data Workflow section for more information, but this included fixing duplicate values, weird/null/empty values, removing useless columns, and 
reassigning IDs when necessary.

Once the cleaning section was over and the data had no issues, I spent time thinking about which metrics were most relevant to analyze. How do the categorical statistics change the numerical stats (like Gender vs Grades)? How do the numerical stats interact with reach other (like Study Hours vs Grades)? 

I discovered that there are several insightful takeaways from the data. These are expanded upon in the Insights & Recommendations section, but they boil down to the following. For
academic success, 1. Medium parental support levels are best, 2. Take more extracurriculars, but not TOO many. 3. Girls tend to perform better academically, but this may be due
to greater variety (and more extreme lows) for boy academic results, 4. Online classes -> more academic success, less extracurricular involvement. 

---

## 2. Objectives


- **Primary Objective:** [Determine the key factors that go into student success.]
- **Secondary Objective 1:** [Evaluate whether categorical or numerical factors hold more weight in determining student success.]
- **Secondary Objective 2:** [Evaluate differences in gender and parenting styles in relation to quantifiable academic metrics.]
- **Secondary Objective 3:** [Explore if the data was of any use, or if it was too randomized to actually draw conclusions from.]

---

## 3. Project Tools

### Tools & Technologies

| Category | Tool(s) Used |
|----------|-------------|
| Data Storage | [MySQL, CSV files] |
| Data Processing | [SQL] |
| Analysis | [SQL, Excel] |
| Visualization | [Excel] |
| Version Control | [Git / GitHub] |
| Documentation | [Markdown, Comments in MySQLWorkbench, Excel ReadMe] |

---

## 4. Repository Structure

```
[project-root]/
│
├── data/
│   ├── raw/                  # Original, unmodified source data - never edited
│   ├── cleaned/            # Cleaned and transformed data
│   
│
├── sql-queries/              # SQL files 
│   ├── proj1.sql/            # A complete MySQL file containing in-depth comments, data cleaning, and data exploration queries
│   ├── README.md/            # More info about the SQL section
│   
│
├── dashboard /               # Excel file, final dashboard
│   ├── final_dashboard.png/  # screenshot of the final dashboard
│   ├── README.md/            # More info about the Excel section
│   ├── students_excel.xslx/  # The excel file with its own ReadMe and Dashboard sheets, pivot tables and data sheets hidden
│
│
│
└── README.md                 # You are here
```


---

## 5. Data Workflow


1. **Source:** Data came from Kaggle, specifically https://www.kaggle.com/datasets/haseebindata/student-performance-predictions. 
2. **Ingestion:** I took this dataset, downloaded it as a CSV file, and put it into MySQL, specifically MySQLWorkbench. The dataset started as 700+ rows of raw Student data. 
3. **Cleaning:** For full thought processes, see the proj1.sql file in the sql-queries folder, but in short the cleaning was extensive. I fixed duplicate students, filled in gaps for unnamed students, reassigned duplicated student ids, edited column names and data types for clarity, handled weird values, removed rows with empty values, removed useless columns, etc. 
4. **Analysis:** I did preliminary analysis with SQL queries, then visual analysis with Excel Pivot Tables and charts.
5. **Output:** The results boil down to a cleaned and queried data table, with a visual dashboard to pull insights from.

---

## 6. Data Model & Schema



### Dataset / Table: `students_staging1`

| Field Name | Data Type | Description | 
|------------|-----------|-------------|
| `StudentID` | int | Unique Student Identifier |
| `Name` | string | Name of Student | 
| `Gender` | string | Gender of Student | 
| `AttendanceRate` | int | Overall Attendance Stat | 
| `StudyHoursPerWeek` | int | self-explanatory | 
| `PreviousGrade` | int | Grade in Previous Class | 
| `ExtracurricularActivities` | int | # Extracurriculars |
| `ParentalSupport` | string | Level of Parental Support |
| `FinalGrade` | int | self-explanatory | 
| `OnlineClassesTakenTF` | boolean | Did the Student take online classes? |

> **Row count (approx.):** 1001 raw, 656 clean.

Note: The only other table I worked with in SQL was the initial raw data (called 'students'). I turned this into students_staging1 immediately upon starting the processing. 

Note2: The table above does not show the two columns I deleted, "Study Hours" and "Attendance (%)", which were useless/redundant. 


---

## 7. Insights/Recommendations


**Insight 1: Medium Parental Support is best!**
Across levels of parental support, and across genders too, students with a medium amount of parental support tended to have both higher grades as well as 
attendance rates. So the recommendation? Do not be entirely removed from the student's academics, but do not micromanage either. Let the student figure
stuff out as they go, while also providing a supportive backbone for them. 

**Insight 2: More extracurriculars means better academics, up to a certain point.**
We find that as the number of extracurriculars rises from 0->2, study hours and grades both increase gradually. And then at 3 extracurriculars, they both fall.
The takeaway: There are only so many hours in a week. If the student is juggling too many things, it becomes hard to keep up academics. But 2 extracurriculars 
seems to be a sweet spot to convey a hardworking and diversified student. 

**Insight 3: Girls rule, boys drool.**
Ever so slightly, girls have overall higher attendance rates and grades, across the levels of parental support. To be fair, we are using averages only, essentially means. 
This means that extreme values skew our data more, i.e. it is possible that actual "average" boys and girls are the same in academics, but the extreme lows of certain boys
skew the values down for boys overall. Food for thought. 

**Insight 4: Taking online classes means less extracurriculars but better academics.**
Potentially obvious, but I presume this is time-based. The time is takes to do an online class takes away from time that could be spent on extracurriculars. 
At the same time though, taking online classes shows drive and desire to succeed academically, so this makes sense. 


---

## 8. Limitations, & Enhancements

### Limitations and Enhancements
- I made an assumption early on that the dataset was made in good faith, i.e. had at least realistic values rather than outright random ones. It seems though that 
  the data is a bit uninformative at times. The various stats seem to be more random than genuine, which made the EDA part of this iffy at times. Still this
  can happen in real life, as datasets are imperfect all the time. If I could, I would have chosen a dataset that I confirmed beforehand to have "realistic" statistics,
  rather than stats that could easily have been generated by a random number generator.
  - For example, the comparison (the chart on the top right of the dashboard) has virtually NO sensible relation. Previous Grades should definitely have some correlation with Final Grades (a positive
    slope), yet we do not see any clear thing like that in our chart. So clearly, the data is wonky at times. 
    and yet the scatter
- Using Excel online (and avoiding the dramatic cost of buying the desktop app) was financially smart but analytically tricky. The online version is limited, and
  the first example that jumps out is the complete lack of slicers on dashboards, which really would add a lot to it. If I could, that is the first enhancement I would make, as
  the dashboard is a lot more interesting when interactive.
- I would not really call this a limitation, but I almost entirely used averages as a mathematical function across this analysis. It seemed that because the rows were students, averages
  were the best metric to summarize and compare various stats. If I were to enhance it, I would look into what other math functions could show us, e.g. count, sum, etc. For this dataset
  though, averages often were the only sensible thing to use. 


---

## 9. Deliverables

| Deliverable | Location |
|-------------|-------------|
| Full SQL File  | [`sql-queries/proj1.sql`] |
| Full Excel File | [`dashboard/students_excel.xlsx`] |
| Dashboard Image | [`dashboard/final_dashboard.png`] |
| Cleaned Dataset | [`data/cleaned/cleaned_student_data.csv`] |

---

## 10. Author

**[Cooper Phillips]**
[Data Analyst]

- 🔗 [www.linkedin.com/in/cooper-phillips-a84404328]
- 💼 [(https://github.com/CooperP7)]
- 📧 [cooperjp1221@gmail.com]

---

*Last updated: [July 2026]*
