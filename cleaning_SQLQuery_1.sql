Select * from dbo.[Nashville Housing Data for Data Cleaning]

-- Standardize Date Format
Select SaleDate ,Convert(Date,SaleDate)
from dbo.[Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
Set SaleDate = CONVERT(Date,SaleDate)

--Populate Property Address
Select *
from dbo.[Nashville Housing Data for Data Cleaning]


Select a.parcelId,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.[Nashville Housing Data for Data Cleaning] a
JOIN dbo.[Nashville Housing Data for Data Cleaning] b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

-- Breaking out Address into  Individual COlumns
Select PropertyAddress
from dbo.[Nashville Housing Data for Data Cleaning]

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

from dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity NVARCHAR(255);

UPDATE dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


Select OwnerAddress
From dbo.[Nashville Housing Data for Data Cleaning]

Select 
ParseName(Replace(OwnerAddress,',','.'),3),
ParseName(Replace(OwnerAddress,',','.'),2),
ParseName(Replace(OwnerAddress,',','.'),1)

From dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'),3)

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'),2)

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState NVARCHAR(255);

UPDATE dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in Sold as Vacant Field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From dbo.[Nashville Housing Data for Data Cleaning]
Group By SoldAsVacant
order by 2

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' then 'Yes'
      When SoldAsVacant = 'N' then 'No'
      Else SoldAsVacant
      End
From dbo.[Nashville Housing Data for Data Cleaning]

Update dbo.[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
      When SoldAsVacant = 'N' then 'No'
      Else SoldAsVacant
      End

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
    Row_Number()Over(
        Partition by ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
                   Order BY
                   UniqueID
                   )row_num
From dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num >1
ORDER BY PropertyAddress

--Delete Unused Columns
Select *
from dbo.[Nashville Housing Data for Data Cleaning]

Alter TABLE dbo.[Nashville Housing Data for Data Cleaning]
Drop COlumn OwnerAddress,TaxDistrict,PropertyAddress

Alter TABLE dbo.[Nashville Housing Data for Data Cleaning]
Drop Column SaleDate
