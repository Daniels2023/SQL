/* 

Cleaning data in SQL queries

*/

SELECT *
From DataCleaning.dbo.NashvilleHousing

-----------------------------------

-- Standardize date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
From DataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------

-- Populate property address data

SELECT *
From DataCleaning.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
From DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
JOIN DataCleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-----------------------------------

-- Breaking out address into individual columns (address, city, state) using Substring

SELECT PropertyAddress
From DataCleaning.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From DataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

SELECT *
From DataCleaning.dbo.NashvilleHousing

-- Breaking out address into individual columns (address, city, state) using PARSENAME

SELECT OwnerAddress
From DataCleaning.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From DataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
From DataCleaning.dbo.NashvilleHousing

------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct (SoldAsVacant), count(SoldAsVacant)
From DataCleaning.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant
,CASE When SoldAsVacant = 'N' Then 'No'
	 When SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
END
From DataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'N' Then 'No'
	 When SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
END


-------------------------------------

--Remove duplicates using CTE, ROW_NUMBER() and PARTITION BY Windows function and OVER clause.

WITH Row_num_CTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From DataCleaning.dbo.NashvilleHousing
)
DELETE
From Row_num_CTE
Where row_num > 1



--------------------------------------

-- Remove unused columns and create views

ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

CREATE VIEW New_view AS
SELECT * 
From DataCleaning.dbo.NashvilleHousing









---------------------------------------
--------------------------------------- 