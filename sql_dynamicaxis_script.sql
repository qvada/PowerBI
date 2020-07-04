/****** Object:  Schema [pbi]    Script Date: 4-7-2020 13:51:55 ******/
 
 /*
 Use at your own risk. Code is AS IS. If you have any question, just contact me via qvada.com. 
 
 This code assumes the existence of a date table, called DimDate. This table is not provided, because everyone builds it on his own rules. 
 This code just needs the usual datetable columns, like date, month, quarter, week(+year) and year. 
 
 
 
 */
 
 
 
CREATE SCHEMA [pbi]
GO
/****** Object:  View [pbi].[DimAxisVariants]    Script Date: 4-7-2020 13:51:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [pbi].[DimAxisVariants]
              AS
                            
              
Select T.Id, T.[Date], T.[Axis Order], T.[Axis Type], T.[Axis Type Id], T.[Axis Year],
              VARIANT.AxisVariant As [Axis Variant],
              COALESCE(ALTERNATE.Label, [Axis Label]) As [Axis Label],
              COALESCE(ALTERNATE.CustomSort, ALTERNATE.OrderingMultiplier * [Axis Order], [Axis Order] * VARIANT.OrderingMultiplier) As [Axis Label Order],
              IIF([Axis Year]!=0, 'Periods', COALESCE(ALTERNATE.Label, [Axis Label])) As [Column Type]


FROM (
              --YEAR
              SELECT 
                            1000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            DD.[Date] As [Date],
                            CAST(DD.[Year] AS VARCHAR(50)) As [Axis Label],
                            DD.[Year] As [Axis Order],
                            'Year' As [Axis Type],
                            1 As [Axis Type Id],   
                            DD.[Year] As [Axis Year]
              FROM [pbi].[DimDate] DD       
              UNION ALL
              --Quarter
              SELECT 
                            2000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            DD.[Date] As [Date],
                            CAST(DD.[Quarter] as varchar(50)) As [Axis Label],
                            CAST(DD.[Quarter] as INT) As [Axis Order],
                            'Quarter' As [Axis Type],
                            2 As [Axis Type Id],   
                            DD.[Year] As [Axis Year]
              FROM [pbi].[DimDate] DD       
              UNION ALL
              --MONTH
              SELECT 
                            3000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            DD.[Date] As [Date],
                            DD.[MonthName] As [Axis Label],
                            CAST(DD.[Month] AS INT) As [Axis Order],
                            'Month' As [Axis Type],
                            3 As [Axis Type Id],   
                            DD.[Year] As [Axis Year]            
              FROM [pbi].[DimDate] DD
              UNION ALL 
              --WEEK
              SELECT 
                            4000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            DD.[Date] As [Date],
                            CAST(DD.[WeekOfYear] AS varchar(50)) As [Axis Label],
                            CAST(DD.[WeekOfYear] AS INT) As [Axis Order],
                            'Week' As [Axis Type],
                            4 As [Axis Type Id],   
                            DD.[Year] As [Axis Year]             
              FROM [pbi].[DimDate] DD
              UNION ALL
              SELECT 
                            6000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            DD.[Date] As [Date],
                            CAST(DD.[Date] As varchar(12)) As [Axis Label],
                            CAST(FORMAT(DD.[Date],'yyyyMMdd') AS INT) As [Axis Order],
                            'Day' As [Axis Type],
                            5 As [Axis Type Id],   
                            DD.[Year] As [Axis Year]           
              FROM [pbi].[DimDate] DD          
			  UNION ALL
			  --Placeholder columns
              SELECT 
                            99000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            '9999-01-01' As [Date],
                            'Difference' As [Axis Label],
                            999999999999 As [Axis Order],
                            'DIFF' As [Axis Type],
                            9 As [Axis Type Id],   
                            0 As [Axis Year]           
              FROM [pbi].[DimDate] DD        
			  UNION ALL
			  --Placeholder columns
              SELECT 
                            98000000000 + 
                            ROW_NUMBER() OVER(ORDER BY (Select 1)) as Id,
                            '9999-01-01' As [Date],
                            'Average' As [Axis Label],
                            999999999998 As [Axis Order],
                            'AVG' As [Axis Type],
                            9 As [Axis Type Id],   
                            0 As [Axis Year]           
              FROM [pbi].[DimDate] DD        
             
                            
) T
CROSS JOIN (     
              Select 'Periods and measure 4 digit year (asc)' As AxisVariant,
                            1 As OrderingMultiplier
              UNION ALL
              Select 'Periods and measure 4 digit year (desc)' As AxisVariant,
                            -1 As OrderingMultiplier
              UNION ALL
              Select 'Periods and measure 2 digit year (asc)' As AxisVariant,
                            1 As OrderingMultiplier
              UNION ALL
              Select 'Periods and measure 2 digit year (desc)' As AxisVariant,
                            -1 As OrderingMultiplier
              --UNION ALL
              --Select 'Periods and measure no year (asc)' As AxisVariant,
              --              1 As OrderingMultiplier
              --UNION ALL
              --Select 'Periods and measure no year (desc)' As AxisVariant,
              --              -1 As OrderingMultiplier
) VARIANT
--Alternative labels and ordering (with this view you can overrride defaults)
LEFT OUTER JOIN (              
              SELECT 
                                          'Periods and measure 4 digit year (asc)' As AxisVariant,
                                          2 As [Axis Type Id],
                                          DD.[YYYYQQ] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(DD.[QuarterName] As Varchar(10)) + ' ' + CAST(DD.[Year] AS varchar(4)) As [Label],                                          
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure 4 digit year (asc)' As AxisVariant,
                                          3 As [Axis Type Id],
                                          DD.[YYYYMM] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          DD.[MonthName] + ' ' + CAST(DD.[Year]  AS varchar(4)) As [Label],                                          
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                                   
              UNION ALL 
              SELECT					  'Periods and measure 4 digit year (desc)' As AxisVariant,
                                          9 AS [Axis Type Id],
                                          999999999999 As CustomSort,
                                          NULL As OrderingMultiplier,
                                          'Mediaan' As [Label],
                                          CAST('9999-01-01' As Date) As [Date]

              UNION ALL
              SELECT 
                                          'Periods and measure 4 digit year (desc)' As AxisVariant,
                                          2 As [Axis Type Id],
                                          -1 * DD.[YYYYQQ] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          DD.[QuarterName] + ' ' + CAST(DD.[Year] AS varchar(4)) As [Label],                                          
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure 4 digit year (desc)' As AxisVariant,
                                          3 As [Axis Type Id],
                                          -1 * DD.[YYYYMM] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          DD.[MonthName] + ' ' + CAST(DD.[Year] AS varchar(4)) As [Label],                                          
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                                   
              UNION ALL
              SELECT 
                                          'Periods and measure 2 digit year (asc)' As AxisVariant,
                                          1 As [Axis Type Id],
                                          DD.[Year] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(RIGHT(DD.[Year],2) AS varchar(4)) As [Label],                              
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure 2 digit year (asc)' As AxisVariant,
                                          2 As [Axis Type Id],
                                          DD.[YYYYQQ] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          DD.[QuarterName] + ' ''' + CAST(RIGHT(DD.[Year],2)  AS varchar(4)) As [Label],                               
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure 2 digit year (asc)' As AxisVariant,
                                          3 As [Axis Type Id],
                                          DD.[YYYYMM] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(DD.[MonthName] AS varchar(50)) + ' ''' + CAST(RIGHT(DD.[Year],2) AS varchar(50))  As [Label],                                         
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD       
              UNION ALL
              SELECT 
                                          'Periods and measure 2 digit year (desc)' As AxisVariant,
                                          1 As [Axis Type Id],
                                          -1 * DD.[Year] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(RIGHT(DD.[Year],2) AS varchar(4)) As [Label],                              
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure 2 digit year (desc)' As AxisVariant,
                                          2 As [Axis Type Id],
                                          -1 * DD.[YYYYQQ] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          DD.[QuarterName] + ' ''' + CAST(RIGHT(DD.[Year],2) AS varchar(4)) As [Label],                               
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure 2 digit year (desc)' As AxisVariant,
                                          3 As [Axis Type Id],
                                          -1 * DD.[YYYYMM] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          DD.[MonthName] + ' ''' + CAST(RIGHT(DD.[Year],2) AS varchar(4)) As [Label],                                         
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD       
              UNION ALL
              SELECT 
                                          'Periods and measure no year (desc)' As AxisVariant,
                                          2 As [Axis Type Id],
                                          -1 * DD.[YYYYQQ] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(DD.[QuarterName] AS varchar(50)) As [Label],                              
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure no year (desc)' As AxisVariant,
                                          3 As [Axis Type Id],
                                          -1 * DD.[YYYYMM] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(DD.[MonthName]  AS varchar(50)) As [Label],                              
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD       
              UNION ALL
              SELECT 
                                          'Periods and measure no year (asc)' As AxisVariant,
                                          2 As [Axis Type Id],
                                          DD.[YYYYQQ] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(DD.[QuarterName]  AS varchar(50))  As [Label],                              
                                          DD.[Date] As [Date]
              FROM [pbi].[DimDate] DD                     
              UNION ALL
              SELECT 
                                          'Periods and measure no year (asc)' As AxisVariant,
                                          3 As [Axis Type Id],
                                          DD.[YYYYMM] As CustomSort,
                                          NULL As OrderingMultiplier,
                                          CAST(DD.[MonthName] AS varchar(50)) As [Label],                              
                                          DD.[Date] As [PeriodDate]
              FROM [pbi].[DimDate] DD       
) As ALTERNATE
              ON ALTERNATE.AxisVariant = VARIANT.AxisVariant
              AND ALTERNATE.[Axis Type Id] = T.[Axis Type Id]
              AND ALTERNATE.[Date] = T.[Date]



GO
/****** Object:  View [pbi].[DimFrequency]    Script Date: 4-7-2020 13:51:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [pbi].[DimFrequency]
As

Select 10 As [Id], 'Year' As [Axis Type], 'Jaar' As [Axis Frequency]
UNION ALL

Select 20 As [Id], 'Quarter' As [Axis Type], 'Kwartaal' As [Axis Frequency]
UNION ALL

Select 30 As [Id], 'Month' As [Axis Type], 'Maand' As [Axis Frequency]
UNION ALL

Select 40 As [Id], 'Week' As [Axis Type], 'Week' As [Axis Frequency]
UNION ALL

Select 50 As [Id], 'Day' As [Axis Type], 'Dag' As [Axis Frequency]
GO
/****** Object:  View [pbi].[TallyTable]    Script Date: 4-7-2020 13:51:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create View [pbi].[TallyTable]
As
--https://www.sqlservercentral.com/blogs/tally-tables-in-t-sql
WITH Tally (n) AS
(
    -- 1000 rows
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n)
    CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)
    CROSS JOIN (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) c(n)
)
SELECT Top 1000 n * -1 As [Id], n * -1 As [Tally Table Number]
FROM Tally
UNION ALL 
SELECT 0 As [Id], 0 As [Tally Table Number]
UNION ALL 
SELECT Top 1000 n As [Id], n As [Tally Table Number]
FROM Tally
GO
