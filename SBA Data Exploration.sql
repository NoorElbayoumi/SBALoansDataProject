--1--
-- What is the summary of all approved PPP Loans and in the years 2020/2021?
-- How many Unique Lenders in both 2020/2021?

SELECT
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2020

-- Number of Approved Loans: 13,744,538
-- Number of Approved Amount: 627,146,378,380.187
-- Average Size Loan: 45,700.9474488309

SELECT
	YEAR(DateApproved) AS Year_Approved,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2020
GROUP BY YEAR(DateApproved)

-- Number of Approved Loans in 2020: 6,230,314
-- Number of Approved Amount in 2020: 323,305,764,792.754
-- Average Size Loan in 2020: 52,071.4609340152
UNION 

SELECT
	YEAR(DateApproved) AS Year_Approved,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2021
GROUP BY YEAR(DateApproved)

-- Number of Approved Loans in 2021: 7,514,222
-- Number of Approved Amount in 2021: 303,840,613,587.434
-- Average Size Loan in 2021: 40,436.9069059259


-- How many Unique Lenders?
SELECT
	COUNT(DISTINCT OriginatingLender) OriginatingLender,
	YEAR(DateApproved) AS Year_Approved,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2020
GROUP BY YEAR(DateApproved)

-- Unique Lenders in 2020: 9,898

UNION 

SELECT
	COUNT(DISTINCT OriginatingLender) OriginatingLender,
	YEAR(DateApproved) AS Year_Approved,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2021
GROUP BY YEAR(DateApproved)

-- Unique Lenders in 2021: 7548


--2--
-- What are the top 15 Originating Lenders by loan count? What is the total and average in 2020 and 2021?
-- 2020

SELECT TOP 15 OriginatingLender, OriginatingLenderCity, OriginatingLenderState,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2020
GROUP BY OriginatingLender, OriginatingLenderCity, OriginatingLenderState
ORDER BY 3 desc


-- 2021
SELECT TOP 15 OriginatingLender,OriginatingLenderCity, OriginatingLenderState,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) AS Approved_Amount,
	AVG(InitialApprovalAmount) AS Average_Loan_Size
FROM [SBA_Data].[dbo].[sba_public_data]
WHERE YEAR(DateApproved) = 2021
GROUP BY OriginatingLender, OriginatingLenderCity, OriginatingLenderState
ORDER BY 3 desc

--3--
-- What are the top 20 Industries that recieved a PPP Loan in 2020/2021?
-- 2020

WITH cte AS (

	SELECT ncd.Sector, count(LoanNumber) AS Loans_Approved, SUM(CurrentApprovalAmount) Net_Dollars
	FROM [dbo].[sba_public_data] main
	INNER JOIN [dbo].[sba_niacs_sector_codes_descriptions] AS ncd
		ON left(CAST(main.NAICSCode AS VARCHAR), 2) = ncd.LookupCodes
	WHERE YEAR(DateApproved) = 2020 
	GROUP BY ncd.Sector
)
SELECT 
	Sector,Loans_Approved,
	SUM(Net_Dollars) OVER(PARTITION BY sector) AS Net_Dollars,
	CAST(1. * Net_Dollars / SUM(Net_Dollars) OVER() AS DECIMAL(5,2)) * 100 AS "Percent by Amount"  
FROM cte  
ORDER BY 3 desc


-- 2021
WITH cte AS (

	SELECT ncd.Sector, count(LoanNumber) AS Loans_Approved, SUM(CurrentApprovalAmount) Net_Dollars
	FROM [dbo].[sba_public_data] main
	INNER JOIN [dbo].[sba_niacs_sector_codes_descriptions] AS ncd
		ON left(CAST(main.NAICSCode AS VARCHAR), 2) = ncd.LookupCodes
	WHERE YEAR(DateApproved) = 2021 
	GROUP BY ncd.Sector
)
SELECT 
	Sector,Loans_Approved,
	SUM(Net_Dollars) OVER(PARTITION BY sector) AS Net_Dollars,
	CAST(1. * Net_Dollars / SUM(Net_Dollars) OVER() AS DECIMAL(5,2)) * 100 AS "Percent by Amount"  
FROM cte  
ORDER BY 3 desc

--4--
-- How much of the PPP Loans of 2020/2021 have been forgiven?
-- NOTE: Data in Forgivness Amount is identified as CHAR rather than INT, values of 2020 are incorrect.

SELECT 
    COUNT(LoanNumber) AS Count_of_Payments, 
    SUM(ISNULL(TRY_CONVERT(decimal(18,2), ForgivenessAmount), 0)) AS Forgiveness_amount_paid,
    CAST(ROUND(SUM(ISNULL(TRY_CONVERT(decimal(18,2), ForgivenessAmount), 0)) / NULLIF(SUM(ISNULL(TRY_CONVERT(decimal(18,2), CurrentApprovalAmount), 0)), 0) * 100, 2) AS decimal(18,2)) AS Forgiveness_Percentage
FROM sba_public_data
WHERE YEAR(DateApproved) = 2020 
    AND ForgivenessAmount <> '0'
-- 29.15%

--2021
SELECT 
    COUNT(LoanNumber) AS Count_of_Payments, 
    SUM(ISNULL(TRY_CONVERT(decimal(18,2), ForgivenessAmount), 0)) AS Forgiveness_amount_paid,
    CAST(ROUND(SUM(ISNULL(TRY_CONVERT(decimal(18,2), ForgivenessAmount), 0)) / NULLIF(SUM(ISNULL(TRY_CONVERT(decimal(18,2), CurrentApprovalAmount), 0)), 0) * 100, 2) AS decimal(18,2)) AS Forgiveness_Percentage
FROM sba_public_data
WHERE YEAR(DateApproved) = 2021
-- 49.74%

--5--
-- Which year and month with the Highest PPP Loans were approved?

SELECT
	YEAR(DateApproved) AS Year_Approved,
	MONTH(DateApproved) AS Month_Approved,
	COUNT(LoanNumber) AS Number_of_Approved,
	SUM(InitialApprovalAmount) Total_Net_Dollars,
	AVG(InitialApprovalAmount) Average_Loan_Size
FROM sba_public_data
GROUP BY YEAR(DateApproved), MONTH(DateApproved)
ORDER BY 4 DESC
-- Highest year is 2020 with 3,467,271 Loans Approved, 236,423,610,145.997 Total Net Dollars, and an Average Loan Size of 68,445.5155861558