--ENRIQUE GONZALEZ - NASHVILLE CLEANING DATA

select * from nashville;

--1. STANDARDIZE DATE FORMATStandardize Date Format

select saleDateConverted from nashville;

select saleDate, convert(Date,saleDate)
from nashville;

update nashville
set SaleDate = convert(date, saleDate);

Alter table nashville
add saleDateConverted Date;

update nashville
set saleDateConverted = convert(date,saleDate);


--2) POPULATE NULL PROPERTY ADDRESS

select * from nashville
where PropertyAddress is null;

select * from nashville
order by ParcelID;

--fill nulls that have the same parcelID with other IDs that have an address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from nashville a
join nashville b on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from nashville a
join nashville b on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;


select ParcelID, PropertyAddress, Count(*) as CNT
from nashville
group by ParcelID, PropertyAddress
having Count(*) > 1;


--3) BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State)
select PropertyAddress from nashville;

select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as City
from nashville;

alter table nashville
add PropertySplitAddress Nvarchar(255);

update nashville
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


alter table nashville
add PropertySplitCity Nvarchar(255);

update nashville
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress));

select * from nashville;


--Owner Address
select ownerAddress from nashville;

select PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from nashville;


alter table nashville
add OwnerSplitAddress Nvarchar(255);

update nashville
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);


alter table nashville
add OwnerSplitCity Nvarchar(255);

update nashville
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);

alter table nashville
add OwnerSplitState Nvarchar(255);

update nashville
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

select * from nashville;


--4) CHANGE 'Y' AND 'N' TO 'YES' AND 'NO'

select distinct(SoldAsVacant), count(*) as CNT
from nashville
group by SoldAsVacant
order by 2;

select SoldAsVacant, 
	Case when SoldAsVacant = 'Y' Then 'Yes'
		when soldAsVacant = 'N' then 'No'
		else soldAsVacant
	END
from nashville;

update nashville
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
						when soldAsVacant = 'N' then 'No'
						else soldAsVacant
						END;

--5) REMOVE DUPLICATES

With rowNumCTE as (
select *, ROW_NUMBER() over (partition by 
							ParcelID, PropertyAddress, SalePrice, LegalReference Order by UniqueId) row_num
from nashville

)
select * from rowNumCTE
where row_num > 1
order by PropertyAddress;


With rowNumCTE as (
select *, ROW_NUMBER() over (partition by 
							ParcelID, PropertyAddress, SalePrice, LegalReference Order by UniqueId) row_num
from nashville

)
delete from rowNumCTE
where row_num > 1;



--6) DELETE UNUSED COLUMNS
select * from nashville;

alter table nashville
drop column ownerAddress, TaxDistrict, PropertyAddress;

alter table nashville
drop column saleDate;