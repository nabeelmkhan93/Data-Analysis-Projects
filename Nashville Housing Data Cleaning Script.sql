Select *
From Nashville


Select SaleDateUpdated, CONVERT(Date,SaleDate)
From Nashville


ALTER TABLE NashvilleHousing
Add SaleDateUpdated Date;

Update NashvilleHousing
SET SaleDateUpdated = CONVERT(Date,SaleDate)


Select *
From Nashville
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville a
JOIN Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville a
JOIN Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



Select PropertyAddress
From Nashville

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as HouseAddress,
		SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as CITY
		FROM Nashville


ALTER TABLE Nashville
Add PropertyStreetAddress Nvarchar(255);

Update Nashville
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville
Add PropertyCity Nvarchar(255);

Update Nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From Nashville





Select OwnerAddress
From Nashville

Select a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress, ISNULL(a.OwnerAddress,b.OwnerAddress)
From Nashville a
JOIN Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.OwnerAddress is null

--Owner address is not available for duplicate records as well.

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From Nashville



ALTER TABLE Nashville
Add OwnerStreetAddress Nvarchar(255);

Update Nashville
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville
Add OwnerCity Nvarchar(255);

Update Nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville
Add OwnerState Nvarchar(255);

Update Nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Nashville



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nashville


Update Nashville
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Identifying Duplicates

select *  , ROW_NUMBER() over ( partition by ParcelID, PropertyAddress, SaleDate, SalePrice,LegalReference ORDER BY UniqueID
) as row_num
from Nashville;

WITH DUPLICATES AS(
SELECT *  , 
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SaleDate,
				SalePrice,
				LegalReference 
				ORDER BY 
				UniqueID
				) as row_num
From Nashville
)


Select *
From DUPLICATES
Where row_num > 1
Order by PropertyAddress

-- Deleteing duplicates

WITH DUPLICATES AS(
SELECT *  , 
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SaleDate,
				SalePrice,
				LegalReference 
				ORDER BY 
				UniqueID
				) as row_num
From Nashville
)


DELETE
From DUPLICATES
Where row_num > 1



Select *
From Nashville



-- Delete Extra Columns



Select *
From Nashville


ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

























