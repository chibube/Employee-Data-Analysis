Use employees_mod;
/* Create a visualization that provides a breakdown between the male and 
female employees working in the company each year, starting from 1990. */
SELECT 
    YEAR(d.from_date) AS calendar_year,
    e.gender,
    COUNT(e.emp_no) AS num_of_employees
FROM
    t_employees e
        JOIN
    t_dept_emp d ON d.emp_no = e.emp_no
GROUP BY calendar_year , e.gender
HAVING calendar_year >= 1990;

/* Compare the number of male managers to the number of female managers 
from different departments for each year, starting from 1990.*/

SELECT 
    *
FROM
    employees_mod.t_dept_manager
;

SELECT 
    dm.emp_no,
    dm.dept_no,
    d.dept_name,
    dm.from_date,
    dm.to_date,
    YEAR(t.hire_date) AS calendar_year,
    t.gender,
    CASE
     WHEN
            YEAR(dm.to_date) >= t.calendar_year
                AND YEAR(dm.from_date) <= t.calendar_year
        THEN 1
        ELSE 0 
        END as years_active 

FROM
    t_dept_manager dm
        JOIN
    t_employees t ON dm.emp_no = t.emp_no
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
ORDER BY dm.emp_no , t.calendar_year;
    
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

/* Compare the average salary of female versus male employees in the entire 
company until year 2002, and add a filter allowing you to see that per each department. */

SELECT 
    ts.emp_no,
    ts.salary,
    te.gender,
    td.dept_no,
    tds.dept_name,
    e.calendar_year,
    ts.from_date,
    ts.to_date,
    CASE
        WHEN
            e.calendar_year <= YEAR(ts.to_date)
                AND e.calendar_year >= YEAR(ts.from_date)
        THEN
            ts.salary
        ELSE ''
    END AS year_salary
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_salaries ts
        JOIN
    t_employees te ON ts.emp_no = te.emp_no
        JOIN
    t_dept_emp td ON ts.emp_no = td.emp_no
        JOIN
    t_departments tds ON td.dept_no = tds.dept_no
    having year_salary <> '' and calendar_year <= 2002
ORDER BY ts.emp_no , e.calendar_year;

SELECT 
    te.gender,
    tds.dept_name,
    ROUND(AVG(ts.salary), 2) AS annual_salary,
    YEAR(ts.from_date) AS calendar_year
FROM
    t_salaries ts
        JOIN
    t_employees te ON ts.emp_no = te.emp_no
        JOIN
    t_dept_emp td ON ts.emp_no = td.emp_no
        JOIN
    t_departments tds ON td.dept_no = tds.dept_no
group by tds.dept_no, te.gender, calendar_year
having calendar_year <= 2002
order by tds.dept_no;

/* Create an SQL stored procedure that will allow you to obtain the average 
male and female salary per department within a certain salary range. 
Let this range be defined by two values the user can insert when calling the procedure.
Finally, visualize the obtained result-set in Tableau as a double bar chart. */

DELIMITER $$ 
drop procedure average_salaries$$
drop procedure average_salary$$
create procedure average_salaries (IN max_range INT, IN min_range INT)
BEGIN
	select 
		e.gender, 
        round(avg(s.salary), 2) as average_salary,
        ds.dept_name 
    from 
	t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp d ON s.emp_no = d.emp_no
        JOIN
    t_departments ds ON d.dept_no = ds.dept_no
    where s.salary between min_range and max_range
    group by ds.dept_no, e.gender
    order by ds.dept_name;
end $$ 

DELIMITER ;

call average_salaries(90000, 50000);
