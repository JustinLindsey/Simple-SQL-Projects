/*

CLEANING DATA IN SQL QUERIES

*/

-- MySql Workbench would not convert empty cells from Excel into NULL values when importing the table. 
-- This required me to update my table. So I analyzed every column, and looked for those Empty Inputs to convert them into NULL values for further cleaning
UPDATE 
	NashvilleHousing
SET
	UniqueId = CASE UniqueId WHEN '' THEN NULL ELSE UniqueId END,
    ParcelID = CASE ParcelId WHEN '' THEN NULL ELSE ParcelId END,
	LandUse = CASE LandUse WHEN '' THEN NULL ELSE LandUse END,
	PropertyAddress = CASE PropertyAddress WHEN '' THEN NULL ELSE PropertyAddress END,
	SaleDate = CASE SaleDate WHEN '' THEN NULL ELSE SaleDate END,
	SalePrice = CASE SalePrice WHEN '' THEN NULL ELSE SalePrice END,
	LegalReference = CASE LegalReference WHEN '' THEN NULL ELSE LegalReference END, 
    SoldAsVacant = CASE SoldAsVacant WHEN '' THEN NULL ELSE SoldAsVacant END,
    OwnerName = CASE OwnerName WHEN '' THEN NULL ELSE OwnerName END,
    OwnerAddress = CASE OwnerAddress WHEN '' THEN NULL ELSE OwnerAddress END,
    Acreage = CASE Acreage WHEN '' THEN NULL ELSE Acreage END,
	TaxDistrict = CASE TaxDistrict WHEN '' THEN NULL ELSE TaxDistrict END,
	LandValue = CASE LandValue WHEN '' THEN NULL ELSE LandValue END,
    BuildingValue = CASE BuildingValue WHEN '' THEN NULL ELSE BuildingValue END,
	TotalValue = CASE TotalValue WHEN '' THEN NULL ELSE TotalValue END,
	YearBuilt = CASE YearBuilt  WHEN '' THEN NULL ELSE YearBuilt END,
	Bedrooms = CASE Bedrooms WHEN '' THEN NULL ELSE Bedrooms END,
	FullBath = CASE FullBath WHEN '' THEN NULL ELSE FullBath END,
    HalfBath = CASE HalfBath WHEN '' THEN NULL ELSE HalfBath END;
    
SELECT *
FROM NashvilleHousing;

/* ================ POPULATE PROPERTY ADDRESS DATA =================== */
-- Checking to see if matching ParcelId's hold the same PropertyAddress

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID;

SELECT a.ParcelId, b.ParcelId, a.PropertyAddress, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelId = b.ParcelId
    AND a.UniqueId <> b.UniqueId
WHERE a.PropertyAddress IS NULL;

-- This Update grabs the NULL PropertyId's from the original table, then inserts the PropertyAddress from the matching ParcelId

UPDATE NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelId = b.ParcelId
    AND a.UniqueId <> b.UniqueId
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

/* ==================================================================================================*/
/* Breaking out PropertyAddress info into Individual Columns (Address, City) */

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT SUBSTR(PropertyAddress,1, LOCATE(',', PropertyAddress) - 1) AS PropertyAddress,
-- LOCATE(',', PropertyAddress) -- this shows the position of the comma
SUBSTR(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS City
FROM NashvilleHousing;

-- Making a new column for the previous split address and then inserting the entries 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTR(PropertyAddress,1, LOCATE(',', PropertyAddress) - 1);

-- Making a new column for the previous split cities and then inserting the entries 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTR(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) ;

/* ==================================================================================================*/
/* Breaking out OwnerAddress info into Individual Columns (Address, City, State) */

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT 
	SUBSTR(OwnerAddress,1, LOCATE(',', OwnerAddress) - 1) AS OwnerAddress, -- LOCATE(',', OwnerAddress) -- this shows the position of the comma
    
	SUBSTR( 
		SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress)) -- Selects just the City and State portion of the original OwnerAddress
		, 1 , -- Position 1 as the starting postition
		LOCATE(',', SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress) - 1) ) -1 -- Ending the string once it hits the comma
		) AS City,
	SUBSTR(
		SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress)) -- Selects the city and state portion of the original OwnerAddress
        , LOCATE(',', SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress) -1) ) +1,  -- Starts that the first comma 
        TRIM(LENGTH(SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress)) )) -- ends at the end of the string
		) AS State
FROM NashvilleHousing;
 
 -- Making a new column for the previous split OwnerAddress and then inserting the entries 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTR(OwnerAddress,1, LOCATE(',', OwnerAddress) - 1) ;

-- Making a new column for the previous split OwnerCities and then inserting the entries 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTR( 
		SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress)) -- Selects just the City and State portion of the original OwnerAddress
		, 1 , -- Position 1 as the starting postition
		LOCATE(',', SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress) - 1) ) -1 -- Ending the string once it hits the comma
		);

-- Making a new column for the previous split OwnerState and then inserting the entries 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTR(
		SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress)) -- Selects the city and state portion of the original OwnerAddress
        , LOCATE(',', SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress) -1) ) +1,  -- Starts that the first comma 
        TRIM(LENGTH(SUBSTR(OwnerAddress, LOCATE(',', OwnerAddress) + 1, LENGTH(OwnerAddress)) )) -- ends at the end of the string
		) ;



/* =================================================================================== */
/* -------- Changing  All the 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" field ----------------- */

-- Showing that the majority of entries say Yes and No
SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Case that changes 'Y and N' to 'Yes and No' respectively
SELECT
	SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
    END
FROM NashvilleHousing;

-- Updating the original table with the previous Query
Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
    END;

/* =========================================================================================== */ 
/* ------------- Removing Duplicates ----------------- */

WITH RowNumCTE AS(
SELECT UniqueId,
	ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
				PropertyAddress,
                SaleDate,
                SalePrice,
                LegalReference
                ORDER BY
					UniqueID)
				AS row_num
FROM NashvilleHousing) 
DELETE nh 
FROM NashvilleHousing nh JOIN rownumCTE r 
	ON nh.UniqueID = r.UniqueID 
WHERE row_num >1;

/* =========================================================================================== */ 
/* ------------- Deleting Unused Columns ----------------- */

-- Deleting columns that we have already cleaned up in the queries above
ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict,
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress;

-- Looking at the data one last time to observe all the changes
SELECT *
FROM NashvilleHousing







