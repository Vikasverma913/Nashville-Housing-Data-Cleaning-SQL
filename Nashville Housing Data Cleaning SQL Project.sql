SELECT * FROM dbo.Nashville_Housing_Data

--Standardised Date Format
SELECT SaleDate, CONVERT(Date, SaleDate) FROM dbo.Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD SaleDateUpdated Date;


UPDATE Nashville_Housing_Data
SET SaleDateUpdated = CONVERT(Date, SaleDate)

SELECT SaleDateUpdated FROM dbo.Nashville_Housing_Data
--We can also check the new column added at the end of the table
SELECT * FROM dbo.Nashville_Housing_Data

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--Populate Property Addreess Data (filling the NULL values)
SELECT PropertyAddress FROM dbo.Nashville_Housing_Data
WHERE PropertyAddress IS NULL

--finding duplicate ParcelIDS (same parcel IDs also have same Property Address)
SELECT * FROM dbo.Nashville_Housing_Data
ORDER BY ParcelID

--Self Joining the table
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM dbo.Nashville_Housing_Data a
JOIN dbo.Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Now that we have found the Property Addresses with same ParcelIDs which are null
--we can copy the addresses from b.Property Address to populate them
--(NOTE - We can do this because same Paercel IDs have same PropertyAddress)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Nashville_Housing_Data a
JOIN dbo.Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Nashville_Housing_Data a
JOIN dbo.Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress FROM dbo.Nashville_Housing_Data

--using substring and character inex to do so
--First for PropertyAddress
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD New_Property_Address NVARCHAR(255);
UPDATE Nashville_Housing_Data
SET New_Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing_Data
ADD Property_City NVARCHAR(255);
UPDATE Nashville_Housing_Data
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Now for OwnerAddress
SELECT OwnerAddress FROM dbo.Nashville_Housing_Data

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
ADD Updated_Owner_Address NVARCHAR(255);
UPDATE Nashville_Housing_Data
SET Updated_Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing_Data
ADD Owner_City NVARCHAR(255);
UPDATE Nashville_Housing_Data
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing_Data
ADD Owner_State NVARCHAR(255);
UPDATE Nashville_Housing_Data
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Checking for final results
SELECT * FROM dbo.Nashville_Housing_Data

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold As Vacant' Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM dbo.Nashville_Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM dbo.Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--Remove Duplicates

SELECT * FROM dbo.Nashville_Housing_Data


SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.Nashville_Housing_Data
ORDER BY ParcelID


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.Nashville_Housing_Data
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.Nashville_Housing_Data
)
DELETE FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

--Deleting Unused Columns
SELECT * FROM dbo.Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Nashville_Housing_Data
DROP COLUMN SaleDate

