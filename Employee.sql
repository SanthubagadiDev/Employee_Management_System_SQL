CREATE SCHEMA Employee_Project;

USE Employee_Project;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);



## Project Analysis - Employee Insights

# 1. How many unique employees are currently in the system?

SELECT COUNT(CONCAT(FIRSTNAME, LASTNAME)) AS UNIQUEEMPLOYEES FROM EMPLOYEE;

# 2. Which departments have the highest number of employees?

SELECT J.JOBDEPT, COUNT(E.EMP_ID) AS COUNT FROM JOBDEPARTMENT J
LEFT JOIN EMPLOYEE E
ON J.JOB_ID = E.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY COUNT DESC;

# 3. What is the average salary per department?

SELECT J.JOBDEPT, AVG(S.AMOUNT) AS MONTHAVG, AVG(S.ANNUAL) AS ANNUALAVG
FROM JOBDEPARTMENT J LEFT JOIN
SALARYBONUS S ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT;

# 4. Who are the top 5 highest-paid employees?

SELECT CONCAT(E.FIRSTNAME,' ', E.LASTNAME) AS NAME, S.AMOUNT
FROM EMPLOYEE E
LEFT JOIN SALARYBONUS S
ON E.JOB_ID = S.JOB_ID
ORDER BY S.AMOUNT DESC
LIMIT 5;

# 5. What is the total salary expenditure across the company?

SELECT SUM(AMOUNT) AS MONTHLY_EXPENDITURE, SUM(ANNUAL) AS ANNUAL_EXPENDITURE
FROM SALARYBONUS;


## Project Analysis - JOB ROLE AND DEPARTMENT ANALYSIS

# 1. How many different job roles exist in each department?

SELECT JOBDEPT, COUNT(NAME) AS JOBROLES_COUNT FROM JOBDEPARTMENT
GROUP BY JOBDEPT;

# 2. What is the average salary range per department?

SELECT J.JOBDEPT, AVG(S.AMOUNT) AS AVG_SALARY_MONTHLY, AVG(S.ANNUAL) AS AVG_SALARY_ANNUALLY 
FROM JOBDEPARTMENT J
LEFT JOIN SALARYBONUS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT;

# 3. Which job roles offer the highest salary?

SELECT J.NAME, MAX(S.AMOUNT) AS HIGH_SALARY_MONTHLY 
FROM JOBDEPARTMENT J
LEFT JOIN SALARYBONUS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.NAME
ORDER BY HIGH_SALARY_MONTHLY DESC;

# 4. Which departments have the highest total salary allocation?

SELECT J.JOBDEPT, SUM(S.AMOUNT) AS HIGH_TOTAL_SAL_MON FROM JOBDEPARTMENT J
LEFT JOIN SALARYBONUS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY HIGH_TOTAL_SAL_MON DESC;


## Project Analysis - QUALIFICATION AND SKILLS ANALYSIS

# 1. How many employees have at least one qualification listed?

SELECT COUNT(DISTINCT(EMP_ID)) AS COUNT_EMPLOYEES FROM QUALIFICATION;

# 2. Which positions require the most qualifications?

SELECT POSITION, COUNT(QUALID) AS qualification_count
FROM QUALIFICATION
GROUP BY POSITION
ORDER BY qualification_count DESC;


# 3. Which employees have the highest number of qualifications?

SELECT CONCAT(E.FIRSTNAME, ' ', E.LASTNAME) AS NAME, COUNT(Q.QUALID)
FROM EMPLOYEE E
LEFT JOIN QUALIFICATION Q
ON E.EMP_ID = Q.EMP_ID
GROUP BY NAME 
ORDER BY COUNT(Q.QUALID) DESC;

## Project Analysis - LEAVE AND ABSENCE PATTERNS

# 1. Which year had the most employees taking leaves?

SELECT YEAR(DATE), COUNT(EMP_ID) FROM LEAVES
GROUP BY YEAR(DATE)
ORDER BY COUNT(EMP_ID) DESC
LIMIT 1;

# 2. What is the average number of leave days taken by its employees per department?

SELECT J.JOBDEPT, COUNT(L.LEAVE_ID)/COUNT(L.EMP_ID) AS AVG_LEAVEDAYS_DEPT
FROM JOBDEPARTMENT J
INNER JOIN EMPLOYEE E
INNER JOIN LEAVES L
ON J.JOB_ID = E.JOB_ID AND E.EMP_ID = L.EMP_ID
GROUP BY J.JOBDEPT;

# 3. Which employees have taken the most leaves?

SELECT CONCAT(E.FIRSTNAME, ' ', E.LASTNAME) AS NAME,COUNT(L.LEAVE_ID) AS LEAVES_TAKEN
FROM EMPLOYEE E 
LEFT JOIN LEAVES L
ON E.EMP_ID = L.EMP_ID
GROUP BY NAME
ORDER BY LEAVES_TAKEN DESC;

# 4. What is the total number of leave days taken company-wide?

SELECT COUNT(DISTINCT(LEAVE_ID)) AS COUNT_LEAVES FROM LEAVES;

# 5. How do leave days correlate with payroll amounts?

SELECT L.emp_ID, COUNT(L.leave_ID) AS leave_days, P.total_amount
FROM Leaves L
JOIN Payroll P ON L.emp_ID = P.emp_ID
GROUP BY L.emp_ID, P.total_amount
ORDER BY leave_days DESC;

## Project Analysis - PAYROLL AND COMPENSATION ANALYSIS

# 1. What is the total monthly payroll processed?

SELECT MONTH(DATE),SUM(TOTAL_AMOUNT) 
FROM PAYROLL
GROUP BY MONTH(DATE);

# 2. What is the average bonus given per department?

SELECT J.JOBDEPT, AVG(S.BONUS)
FROM JOBDEPARTMENT J
LEFT JOIN SALARYBONUS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT;

# 3. Which department receives the highest total bonuses?

SELECT J.JOBDEPT, SUM(S.BONUS) AS BONUS
FROM JOBDEPARTMENT J
LEFT JOIN SALARYBONUS S
ON J.JOB_ID = S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY BONUS DESC;

# 4. What is the average value of total_amount after considering leave deductions?

SELECT CONCAT(E.FIRSTNAME, ' ' , E.LASTNAME) AS NAME, AVG(P.TOTAL_AMOUNT) AS FINAL_AMOUNT
FROM EMPLOYEE E
LEFT JOIN PAYROLL P
ON E.EMP_ID = P.EMP_ID
GROUP BY NAME
ORDER BY FINAL_AMOUNT DESC;