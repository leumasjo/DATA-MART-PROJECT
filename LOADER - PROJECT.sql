USE Project
GO

/****************************************************************************/
/*********************  DIM AREA LOADER  ***********************************/
/*******************************************************************************/
INSERT INTO dim.Area(Area_Code, Area)
SELECT psda.Area_Code
		  ,psda.Area
FROM Project.stg.dim_Area psda
WHERE NOT EXISTS (
SELECT 1
FROM dim.Area da
WHERE da.Area_Code=psda.Area_Code)
;

/****************************************************************************/
/*********************  DIM ITEM LOADER  ***********************************/
/*******************************************************************************/
INSERT INTO dim.Item(ItemCode, Item)
SELECT psdi.ItemCode
		  ,psdi.Item
FROM Project.stg.dim_Item psdi
WHERE NOT EXISTS (
SELECT 1
FROM dim.Item di
WHERE di.ItemCode=psdi.ItemCode)
;

/****************************************************************************/
/*********************  DIM CALEDAR LOADER  ***********************************/
/*******************************************************************************/

DECLARE @Year INT;
-- Loop through the years from 1990 to 2013
SET @Year = 1990;

WHILE @Year <= 2013
BEGIN
    -- Insert the Year into dim.Calendar table only if it doesn't already exist
    INSERT INTO dim.Calendar (pkCalendarID, [Year])
    SELECT 
        (@Year - 1990) * 10000 + 1 AS pkCalendarID,  -- Generate pkCalendarID
        @Year AS [Year]                              -- Insert the Year
    WHERE NOT EXISTS (
        SELECT 1
        FROM dim.Calendar dc
        WHERE dc.[Year] = @Year
    );

    -- Move to the next year
    SET @Year = @Year + 1;
END;


/****************************************************************************/
/*********************  FACT TABLE LOADER  ***********************************/
/*******************************************************************************/

INSERT INTO f.fact(Area_Code,ItemCode,	Year, hg_ha_Yield, Average_rainfall,pesticides,	avg_temp, Min_Rainfall_Reqd, Weather_Index_Insurance)

	SELECT sq.Area_Code as f_Area_Code,
		sq.ItemCode as f_ItemCode,
		sq.Year as f_Year,
		sq.[hg/ha_yield] as f_Yield,
		sq.average_rain_fall_mm_per_year as f_Avg_rainfall,
		sq.pesticides_tonnes as f_pesticides,
		sq.avg_temp as f_avg_temp,
		sq.[Min_Rainfall-Reqd] as f_min_rainfall_required,
		sq.Weather_Index_Insurance as f_WI_Insurance
	FROM stg.qfact sq
	WHERE NOT EXISTS (
	SELECT 1
	FROM f.fact ff
	WHERE sq.ItemCode = ff.ItemCode
	AND sq.Area_Code = ff.Area_Code
	AND sq.Year	= ff.Year
	);

Go


--QUESTIONS TO ANSWER

--1. What is the total yield of each crop from 2010 to 2013 for only selected six countries, Canada, Mexico, Ghana, Kenya,India and Spain

SELECT 
    ff.ItemCode AS CropID,
    di.Item AS CropName,
    SUM(ff.hg_ha_Yield) AS TotalYield
FROM 
    f.fact ff
INNER JOIN 
    dim.Area da
ON 
    ff.Area_Code = da.Area_Code
INNER JOIN 
    dim.Item di
ON 
    ff.ItemCode = di.ItemCode
INNER JOIN 
    dim.Calendar dc
ON 
    ff.[Year] = dc.[Year]
WHERE 
    dc.[Year] BETWEEN 2010 AND 2013
    AND da.Area IN ('Mexico', 'Canada', 'India', 'Kenya', 'Ghana', 'Spain')
GROUP BY 
    ff.ItemCode, di.Item
ORDER BY 
    TotalYield DESC;


	--2. Total yield of each crop planted in Canada between 2010 and 2013, to know which crop has the highest yield?
SELECT 
    ff.ItemCode AS CropID,
    di.Item AS CropName,
    SUM(ff.hg_ha_Yield) AS TotalYield
FROM 
    f.fact ff
INNER JOIN 
    dim.Area da
ON 
    ff.Area_Code = da.Area_Code
INNER JOIN 
    dim.Item di
ON 
    ff.ItemCode = di.ItemCode
INNER JOIN 
    dim.Calendar dc
ON 
    ff.[Year] = dc.[Year]
WHERE 
    dc.[Year] BETWEEN 2010 AND 2013
    AND da.Area = 'Canada'
GROUP BY 
    ff.ItemCode, di.Item
ORDER BY 
    TotalYield DESC;

--3.	What is the total pesticides used by each of the six countries between 2010 and 2013?

SELECT 
    da.Area AS Country,
    SUM(ff.pesticides) AS TotalPesticides
FROM 
    f.fact ff
INNER JOIN 
    dim.Area da
ON 
    ff.Area_Code = da.Area_Code
INNER JOIN 
    dim.Calendar dc
ON 
    ff.[Year] = dc.[Year]
WHERE 
    dc.[Year] BETWEEN 2010 AND 2014
    AND da.Area IN ('Mexico', 'Canada', 'India', 'Kenya', 'Ghana', 'Spain')
GROUP BY 
    da.Area
ORDER BY 
    TotalPesticides DESC;


--4.	a. What is the total number of WI insurance claims for each country. 
--      b. Which countries and crops have the highest number of weather index insurance claims between 2010 and 2014?

	SELECT 
    da.Area AS Country,
    di.Item AS Crop,
    COUNT(*) AS ClaimsCount
FROM 
    f.fact ff
INNER JOIN 
    dim.Area da
ON 
    ff.Area_Code = da.Area_Code
INNER JOIN 
    dim.Item di
ON 
    ff.ItemCode = di.ItemCode
INNER JOIN 
    dim.Calendar dc
ON 
    ff.[Year] = dc.[Year]
WHERE 
    dc.[Year] BETWEEN 2010 AND 2014
    AND da.Area IN ('Mexico', 'Canada', 'India', 'Kenya', 'Ghana', 'Spain')
    AND ff.Weather_Index_Insurance = 'Claim'
GROUP BY 
    da.Area, di.Item
ORDER BY 
    ClaimsCount DESC;


	