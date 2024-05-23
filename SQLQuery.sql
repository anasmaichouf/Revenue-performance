DESKTOP-Q5ENFDR

ALTER TABLE ServiceBranchDB..Service_Data
ADD CONSTRAINT fk_branch_id
FOREIGN KEY (branch_id) REFERENCES Branch_Data(Branch_ID)

-- Show All Data of Service

Select * From Service_Data

-- Revenue by Region

Select b.Region, SUM(s.total_revenue) as TotalRevenue
From ServiceBranchDB..Service_Data s
Join ServiceBranchDB..Branch_Data b ON s.branch_id = b.Branch_ID
Group by b.Region
Order by TotalRevenue Desc

-- Revenue by Department

Select s.department, SUM(total_revenue) as TotalRevenue
From Service_Data s
Group by s.department
Order by TotalRevenue Desc

-- Revenue by Client

Select client_name, SUM(total_revenue) as TotalRevenue
From ServiceBranchDB..Service_Data
Group by client_name
Order by TotalRevenue Desc

-- Total Revenue

Select SUM(total_revenue) as TotalRevenue
From ServiceBranchDB..Service_Data

-- Total Hours

Select SUM(hours) as TotalHours
From ServiceBranchDB..Service_Data

-- Revenue per Department over Overall Revenue

Select	department,
		SUM(total_revenue) as DepartmentRevenue,
		SUM(total_revenue) / (Select sum(total_revenue) from ServiceBranchDB..Service_Data)*100 as RevenuePercentage
From ServiceBranchDB..Service_Data
Group by department

-- Month on month Revenue Increase

WITH MonthlyRevenue AS (
    SELECT 
        FORMAT(service_date, 'yyyy-MM') AS month,
        SUM(total_revenue) AS revenue
    FROM 
        ServiceBranchDB..Service_Data
    GROUP BY 
        FORMAT(service_date, 'yyyy-MM')
),
RevenueComparison AS (
SELECT
month,
revenue,
LAG(revenue) OVER (ORDER BY month) as PreviousMonthRevenue
FROM 
MonthlyRevenue
)
SELECT
month,
revenue,
PreviousMonthRevenue,
((revenue - PreviousMonthRevenue) / PreviousMonthRevenue)*100 as RevenuePercentageIncrease
FROM 
RevenueComparison
WHERE 
PreviousMonthRevenue is not null

-- Revenue % of Overrall Region

Select 
b.Region,
From 
ServiceBranchDB..Service_Data s
join ServiceBranchDB..Branch_Data b ON
s.branch_id = b.Branch_ID


WITH RegionRevenue AS (
    SELECT 
        b.region as region,
        SUM(s.total_revenue) AS region_revenue
    FROM 
        ServiceBranchDB..Service_Data s
	join ServiceBranchDB..Branch_Data b ON s.branch_id = b.Branch_ID
    GROUP BY 
        b.region
),
TotalRevenue AS (
    SELECT 
        SUM(total_revenue) AS total_revenue
    FROM 
        ServiceBranchDB..Service_Data s
)
SELECT 
    region,
    region_revenue,
    (region_revenue / (SELECT total_revenue FROM TotalRevenue)) * 100 AS revenue_percentage_of_overall_region
FROM 
    RegionRevenue, TotalRevenue;


