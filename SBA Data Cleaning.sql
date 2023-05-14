-- Data cleaning goals:
-- 1.) Have the sectors in the first column
-- 2.) Have the number of the sector in column two as a LookupCode
-- 3.) Have the descriptions of the sector in the final column

SELECT *
INTO sba_niacs_sector_codes_descriptions
FROM(
    SELECT [NAICS_Industry_Description],
         IIF([NAICS_Industry_Description] like '%–%', SUBSTRING([NAICS_Industry_Description], 8, 2 ), '') LookupCodes,
		 IIF([NAICS_Industry_Description] like '%–%', LTRIM(SUBSTRING([NAICS_Industry_Description], CHARINDEX('–', [NAICS_Industry_Description]) + 1, LEN([NAICS_Industry_Description]) )), '') Sector
    FROM [SBA_Data].[dbo].[sba_industry_standards]
    WHERE [NAICS_Codes] = ''
) MAIN
WHERE LookupCodes != ''

SELECT TOP (1000) [NAICS_Industry_Description]
      ,[LookupCodes]
      ,[Sector]
  FROM [SBA_Data].[dbo].[sba_niacs_sector_codes_descriptions]
  ORDER BY LookupCodes

  INSERT INTO [dbo].[sba_niacs_sector_codes_descriptions]
	VALUES 
  ('Sector 31 – 33 – Manufacturing', 32, 'Manufacturing'), 
  ('Sector 31 – 33 – Manufacturing', 33, 'Manufacturing'), 
  ('Sector 44 - 45 – Retail Trade', 45, 'Retail Trade'),
  ('Sector 48 - 49 – Transportation and Warehousing', 49, 'Transportation and Warehousing')

 UPDATE  [dbo].[sba_niacs_sector_codes_descriptions]
 SET Sector = 'Manufacturing'
 WHERE LookupCodes = 31