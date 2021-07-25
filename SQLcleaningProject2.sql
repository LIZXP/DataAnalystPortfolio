--Clean the date column

ALTER TABLE [Data Cleaning]..HousingData
ADD SaleDate2 DATE;

UPDATE [Data Cleaning]..HousingData
SET SaleDate2=CONVERT(Date,SaleDate)

ALTER TABLE [Data Cleaning]..HousingData
DROP COLUMN SaleDate

-----------------------------------------------------------------------------------------------------
--Complete the Property Address for those are NULL

Select *
From
	[Data Cleaning]..HousingData
WHERE
	PropertyAddress is NULL
ORDER BY
	ParcelID

--JOIN the table using ParcelID to locate the missing address

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
	[Data Cleaning]..HousingData a
JOIN
	[Data Cleaning]..HousingData b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE
	a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
	[Data Cleaning]..HousingData a
JOIN
	[Data Cleaning]..HousingData b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE
	a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------------------------------
--Break the address into different column using SUBSTRING

Select
	PropertyAddress
FROM
	[Data Cleaning]..HousingData

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM
	[Data Cleaning]..HousingData

ALTER TABLE [Data Cleaning]..HousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Data Cleaning]..HousingData
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Data Cleaning]..HousingData
ADD PropertySplitCity Nvarchar(255);

UPDATE [Data Cleaning]..HousingData
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--test split column

SELECT *
FROM [Data Cleaning]..HousingData

--OK!WORKS

--------------------------------------------------------------------------------------------------------------------------
--Splite OwnerAddress Column using PARSENAME

SELECT OwnerAddress
FROM [Data Cleaning]..HousingData

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM 
	[Data Cleaning]..HousingData


ALTER TABLE [Data Cleaning]..HousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Data Cleaning]..HousingData
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Data Cleaning]..HousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Data Cleaning]..HousingData
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Data Cleaning]..HousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE [Data Cleaning]..HousingData
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Test-----------------------------


SELECT *
FROM 
	[Data Cleaning]..HousingData

--works!---------------------------



-------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and NO in "Sold as Vacant" field


--First Count how many Y and N are there

SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM 
	[Data Cleaning]..HousingData
GROUP BY
	SoldAsVacant
ORDER BY 2



SELECT
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'YES' 
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM 
	[Data Cleaning]..HousingData


UPDATE [Data Cleaning]..HousingData
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'YES' 
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------------------------------
--Clean Duplicates

WITH RowCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Data Cleaning]..HousingData
)
DELETE
FROM RowCTE
WHERE row_num > 1

--Test----------------------

WITH RowCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Data Cleaning]..HousingData
)
SELECT *
FROM RowCTE
WHERE row_num > 1

--WORKS!