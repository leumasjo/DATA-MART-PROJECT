USE Project;
GO

/**************************************************************************/
/*********************   SCHEMA DDL  *************************************/
/************************************************************************/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dim' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA dim AUTHORIZATION dbo;'
END
;

GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA stg AUTHORIZATION dbo;'
END
;

GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'f' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA f AUTHORIZATION dbo;'
END
;

GO

/****************************************************************************/
/*********************   AREA DIM DDL   *************************************/
/***************************************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Area')
BEGIN
CREATE TABLE dim.Area(
	Area_Code bigint NOT NULL,
	Area nvarchar(max) NOT NULL
	)
	;

	ALTER TABLE dim.Area
	ADD CONSTRAINT pk_Area PRIMARY KEY(Area_Code);
END;


/****************************************************************************/
/*********************  ITEM DIM DDL   *************************************/
/**************************************************************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Item')
BEGIN
CREATE TABLE dim.Item(
	ItemCode bigint NOT NULL,
	Item nvarchar(max) NOT NULL
	);

	ALTER TABLE dim.Item
	ADD CONSTRAINT pk_Item PRIMARY KEY(ItemCode);
END;


/****************************************************************************/
/*********************  CALENDAR DIM DDL   *************************************/
/*******************************************************************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Calendar')
BEGIN
    CREATE TABLE dim.Calendar (
        pkCalendarID INT NOT NULL,
        Year INT NOT NULL
    );
      ALTER TABLE dim.Calendar
    ADD CONSTRAINT PK_Calendar PRIMARY KEY (pkCalendarID);
     ALTER TABLE dim.Calendar
    ADD CONSTRAINT UC_Calendar UNIQUE (Year);
END;
 
 
	--CREATING FACT TABLE: 'FACT'
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'f' AND TABLE_NAME = 'fact')
BEGIN
CREATE TABLE f.fact(
	Area_Code bigint NOT NULL,
	ItemCode int NOT NULL,
	Year int NOT NULL,
	hg_ha_Yield int NULL,
	Average_rainfall int NULL,
	pesticides int NOT NULL,
	avg_temp int NULL,
	Min_Rainfall_Reqd int NULL,
	Weather_Index_Insurance nvarchar(10)
);

ALTER TABLE f.fact
ADD CONSTRAINT  FK_Item FOREIGN KEY(ItemCode) REFERENCES dim.item(ItemCode);
ALTER TABLE f.fact
ADD CONSTRAINT FK_Area FOREIGN KEY (Area_Code) REFERENCES dim.Area(Area_Code);
ALTER TABLE f.fact
ADD CONSTRAINT FK_Year FOREIGN KEY (Year) REFERENCES dim.Calendar(Year);

END;




