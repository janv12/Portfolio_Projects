/*
Cleaning Data in SQL Queries
*/


select * 
from Portfolio_Project.dbo.Housing



-- Standardize Date Format
alter table Housing
add  SaleDateConverted date;

Update Housing
set SaleDateConverted =convert(date,SaleDate);

select SaleDateConverted
from Portfolio_Project.dbo.Housing;


-----------------------------------------------------------------------------------------------------------------------------------------------------
--populate property adress data
select *
from Portfolio_Project.dbo.Housing
where PropertyAddress is  null
order by ParcelID

select a.ParcelID , a.PropertyAddress ,b.ParcelID,b.PropertyAddress ,isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.Housing as a
Join Portfolio_Project.dbo.Housing as b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where b.PropertyAddress is null

 Update a
 set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
 from Portfolio_Project.dbo.Housing as a
Join Portfolio_Project.dbo.Housing as b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]


 -----------------------------------------------------------------------------------------------------------------------------------------------
 --Breaking out adress into individual columns(address,city,state)
select PropertyAddress
from Portfolio_Project.dbo.Housing

select
substring(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1) as address
,substring(PropertyAddress , CHARINDEX(',' , PropertyAddress)+ 1, len(PropertyAddress)) as address
from Portfolio_Project.dbo.Housing

Alter Table Housing
add PropertySplitAdress Nvarchar(255)

update Housing
set PropertySplitAdress = substring(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1) 


Alter Table Housing
add PropertySplitCity Nvarchar(255)

update Housing
set PropertySplitCity = substring(PropertyAddress , CHARINDEX(',' , PropertyAddress)+ 1, len(PropertyAddress))

select *
from Portfolio_Project.dbo.Housing



select OwnerAddress
from Portfolio_Project.dbo.Housing

select 
PARSENAME(Replace(OwnerAddress ,',','.'),3),
PARSENAME(Replace(OwnerAddress ,',','.'),2),
PARSENAME(Replace(OwnerAddress ,',','.'),1)
from Portfolio_Project.dbo.Housing

Alter Table Housing
add OwnerSplitAdress Nvarchar(255)

update Housing
set  OwnerSplitAdress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table Housing
add OwnerSplitCity Nvarchar(255)

update Housing
set  OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table Housing
add OwnerSplitState Nvarchar(255)

update Housing
set  OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from Portfolio_Project.dbo.Housing




---------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant),count(SoldAsVacant)
from Portfolio_Project.dbo.Housing
	group by (SoldAsVacant)
	order by 2

	select SoldAsVacant
	,case when SoldAsVacant ='Y' then 'Yes'
	      when SoldAsVacant = 'N' then 'No'
		  else SoldAsVacant 
		  end
	from Portfolio_Project.dbo.Housing

	Update Housing
	set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
	      when SoldAsVacant = 'N' then 'No'
		  else SoldAsVacant 
		  end



------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
from Portfolio_Project.dbo.Housing
)
/*
Delete 
from RowNumCTE
where row_num >1
--order by PropertyAddress
*/
Select *
from RowNumCTE
where row_num >1
order by PropertyAddress



-------------------------------------------------------------------------------------------------------
--deleting Unused columns

select *
from Portfolio_Project.dbo.Housing


ALTER TABLE Portfolio_Project.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
