
# STAGE 1 SET RAW DATA ASIDE
# We want to create a staging table of data that we will actually work with, 
# so we do not mess up original data.

# CREATES A STAGING TABLE, THE ONE I WILL WORK WITH
CREATE TABLE students_staging1 
LIKE students;

INSERT students_staging1 
SELECT * 
FROM students;

SELECT * FROM students_staging1;


# CLEANUP TIME! 

# STAGE 2: FIX/REMOVE DUPLICATES 

# FIND STUDENTS THAT SHOW UP MULTIPLE TIMES AND DELETE THEM

Select `Name`, COUNT(*) 
FROM students_staging1 
GROUP BY `Name` HAVING COUNT(*) > 1;

DELETE FROM students_staging1 
WHERE `Name` = "Andrea Frey" OR `Name` = "Anthony Smith" OR `Name` = "Erica Miller";

# WE CAN KEEP PEOPLE WITHOUT A NAME, WE WILL RENAME THEM "UNKNOWN"
UPDATE students_staging1
SET `Name` = "Unknown" 
	WHERE `Name` = "";

SELECT * FROM students_staging1 WHERE `Name` = "";


# MULTIPLE STUDENTS HAVE THE SAME ID, SO WE CANNOT SIMPLY REMOVE THEM. WE MUST REASSIGN THOSE STUDENT IDS. 

WITH max_num AS 
	(
    # FIND MAX NUMBER OF ID TO ASSIGN NEW IDS AFTER THAT POINT
	SELECT MAX(StudentID) AS maxi
	FROM students_staging1
    ),
	dups AS 
	(
	SELECT StudentID, `Name`,
	# ASSIGN ROW NUMS
	ROW_NUMBER() OVER (ORDER BY StudentID, `Name`) AS seq_num
	FROM students_staging1
	# WHERE IDS ARE DUPLICATES
	WHERE StudentID IN 
    (
		SELECT StudentID 
		FROM students_staging1 
		GROUP BY StudentID 
		HAVING COUNT(*) > 1
	)
)
# UPDATE THE TABLE, NOW NO ONE SHARES AN ID 
UPDATE students_staging1 s
JOIN dups d
    ON s.StudentID = d.StudentID AND s.`Name` = d.`Name`
CROSS JOIN max_num m
SET s.StudentID = m.maxi + d.seq_num;

# CHECK IT, NOTHING LEFT! 
SELECT StudentID 
FROM students_staging1 
GROUP BY StudentID 
HAVING COUNT(*) > 1;



# STAGE 3, STANDARDIZE VALUES -> FIX ISSUES 

#In case of spacing issues with names
UPDATE students_staging1
SET `Name` = TRIM(`Name`);
 
# RENAME COLUMNS THAT HAVE SPACES IN THEIR NAME
SELECT * FROM students_staging1;

ALTER TABLE students_staging1
RENAME COLUMN `Study Hours` TO StudyHours,
RENAME COLUMN `Attendance (%)` TO AttendancePCT,
RENAME COLUMN `Online Classes Taken` TO OnlineClassesTakenTF;

SELECT * FROM students_staging1;

# CHANGE DATA TYPE OF STUDENTID FROM FLOAT TO INT CAUSE INTS ARE MORE COMMON TO WORK WITH
ALTER TABLE students_staging1
MODIFY StudentID INT;


# HANDLE WEIRD VALUES 
SELECT * FROM students_staging1;

SELECT *
FROM students_staging1
WHERE NOT (
    AttendanceRate BETWEEN 0 AND 100
    AND StudyHoursPerWeek >= 0
    AND PreviousGrade BETWEEN 0 AND 100
    AND ExtracurricularActivities >= 0
    AND FinalGrade BETWEEN 0 AND 100
    AND StudyHours >= 0
    AND AttendancePCT BETWEEN 0 AND 100
);

# THE ONLY PROBLEM IS WITH STUDYHOURS AND ATTENDANCEPCT, 
# THESE COLUMNS HAVE 6 ROWS THAT ARE ALL VALUES -5 and 200 respectively

UPDATE students_staging1
SET 
	StudyHours = CASE WHEN StudyHours < 0 THEN NULL ELSE StudyHours END,
    AttendancePCT = CASE WHEN AttendancePCT NOT BETWEEN 0 AND 100 THEN NULL ELSE AttendancePCT END
WHERE StudyHours < 0 OR AttendancePCT NOT BETWEEN 0 AND 100;




# STAGE 4 NULL/BLANK VALUES 

# Because these are statistics about people, we cannot really "guess" at numbers to fill in empty cells. 

SELECT *
FROM students_staging1
WHERE Name IS NULL 
   OR Name = ''
   OR AttendanceRate IS NULL
   OR PreviousGrade IS NULL
   OR StudyHours IS NULL;
   
SELECT *
FROM students_staging1
WHERE 
	`Name` = ""
    OR Gender = ""
    OR AttendanceRate IS NULL
    OR StudyHoursPerWeek IS NULL
    OR PreviousGrade IS NULL
    Or ExtracurricularActivities IS NULL
    OR ParentalSupport = ""
    OR FinalGrade IS NULL
    OR StudyHours IS NULL
    OR AttendancePCT IS NULL
    OR OnlineClassesTakenTF = "";

# 74 rows returned, no blank values for integer columns, only for qualitative metrics, and null vals for weird values from earlier
# We can either
	# 1: Remove the rows from our table (about 1/10th of the table) -> We are going to do this in our staging data table,
	#    because it simply is the safest bet to handle empty cells and we still have 9/10 of our data (600+ rows to look at)
	#    in our raw data table, we still have these students if need be
    # 2: Leave the cells blank -> This would be fine if we truly wanted to keep all students in the table, but since our data
    #    is purely for calculations, we still have 600+ rows/students without these cells, so we will not do this
    # 3: Fill in cells with averages -> This seems silly because this would be 
    #    making up fake values that skew calculations, so I will not be doing this either



DELETE
FROM students_staging1
WHERE 
    Gender = ""
    OR ParentalSupport = ""
    OR StudyHours IS NULL
    OR AttendancePCT IS NULL
    OR OnlineClassesTakenTF = "";

SELECT * FROM students_staging1;



# STAGE 5 REMOVE COLUMNS IF NEED BE



# Deep dive into the significance of AttendanceRate vs AttendancePCT as well as StudyHoursPerWeek vs StudyHours

SELECT AttendanceRate, AttendancePCT FROM students_staging1 ORDER BY AttendanceRate, AttendancePCT;
# SEEMS LIKE THESE COLUMNS ARE VIRTUALLY UNRELATED, 
# AttendanceRate had no weird or missing values, so we will trust that more

SELECT StudyHoursPerWeek, StudyHours  FROM students_staging1 ORDER BY StudyHoursPerWeek, StudyHours;
# StudyHours ranges from 0-5 for some reason, possibly as some sort of continuous distribution rather than
# actual amount of hours  ? Kinda strange and unexplained by data alone. 


# We can keep AttendancePCT and StudyHours in our raw data and staging table but we want to focus more on AttendanceRate 
# and StudyHoursPerWeek so we will drop the other two columns from a new finalized data table

ALTER TABLE students_staging1
DROP COLUMN StudyHours,
DROP COLUMN AttendancePCT;

SELECT * FROM students_staging1;


# An optional last step (depending on our needs) could be to change qualitative columns (like gender, parental support, onlineclassestakentf)
# into quantitative columns in order to make calculations easier and create encoding for ML
# For our purposes we will not need to do that for this project



# This looks all cleaned up then! Let's get to some exploratory queries. 


# Gender and parenting dynamics

# Let's look at gender and parental support in relation to quantitative results 

SELECT Gender, ParentalSupport, ROUND(AVG(FinalGrade), 2), ROUND(AVG(AttendanceRate), 2), ROUND(AVG(StudyHoursPerWeek), 2)
FROM students_staging1
GROUP BY Gender, ParentalSupport
ORDER BY Gender;

# We do find that women tend to have higher final grades and attendance rates while typically studying 
# less in hours per week. Keep in mind that studying may just be more efficient for women 
# and thus require less time. It is unclear from the data. 

# We also find that low parental support actually translates to higher grades and similar if not higher attendance rates 
# than high parental support across boys and girls. Maybe higher parental support means the kids are less motivated? 

# It is worth mentioning that Medium support does have the highest averages in each of the three metrics here though 
# in almost every situation

# How about outside of school, how do people compare?

SELECT Gender, ParentalSupport, AVG(ExtracurricularActivities) AS extracurr
FROM students_staging1
GROUP BY Gender, ParentalSupport
ORDER BY extracurr;

# Virtually no relationship between these 
 
# So what else can we do with this data? Well let's see if the quantitative metrics have a connection. 

SELECT PreviousGrade, AVG(FinalGrade)
FROM students_staging1
GROUP BY PreviousGrade
ORDER BY PreviousGrade;

# This table seems to some degree to have slightly randomized data, because certain correlations certainly 
# would be more pronounced if we had real student data

# Do higher study hours translate to better performance?
SELECT StudyHoursPerWeek, ROUND(AVG(FinalGrade), 2)
FROM students_staging1
GROUP BY StudyHoursPerWeek
ORDER BY StudyHoursPerWeek;
# Seems like there is no correlation. This could mean less studying -> smarter student -> better grade
# as well as more studying -> more motivated -> better grade. It all balances out basically. 

# How about having taken online classes or not?
SELECT OnlineClassesTakenTF, ROUND(AVG(FinalGrade), 2)
FROM students_staging1
GROUP BY OnlineClassesTakenTF
ORDER BY OnlineClassesTakenTF;

# Very slight edge to better grade with having taken online classes, but probably not by a significant margin. 

# How do extracurriculars impact school performance? 

SELECT 
    CASE 
        WHEN ExtracurricularActivities < 1 THEN 'Low Activities'
        WHEN ExtracurricularActivities BETWEEN 1 AND 2 THEN 'Medium Activities'
        ELSE 'High Activites'
    END AS Activities,
    ROUND(AVG(PreviousGrade), 2) AS AvgStartingGrade,
    ROUND(AVG(FinalGrade), 2) AS AvgFinalGrade,
    ROUND(AVG(FinalGrade) - AVG(PreviousGrade), 2) AS GradeImprove,
    ROUND(AVG(AttendanceRate), 2) AS AvgAttend
FROM students_staging1
GROUP BY 
    CASE 
        WHEN ExtracurricularActivities < 1 THEN 'Low Activities'
        WHEN ExtracurricularActivities BETWEEN 1 AND 2 THEN 'Medium Activities'
        ELSE 'High Activites'
    END;


# Less extracurriculars does to some degree mean more school attendance
# Less extracurriculars also means more grade improvement over time
# Maybe less time spent on activities means more time studying to improve grades?


# We can stop here for SQL EDA, We will move the data to an Excel sheet and make some visuals and analyses there

















