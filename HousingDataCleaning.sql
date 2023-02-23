/*
Data Cleaning WithSQL - GoodlettVille Housing Data

ACTIVITIES

-View Data
-Standardize data format(data format)
-Decouple Address Column to Street and City for ease of visualization
-Data Consistency
-Remove Duplicates
Remove unused columns where necessary

*/

select *
from
MyPortfolio..Goodlettville

--STANDARDIZE DATA FORMAT

select SaleDate
from
MyPortfolio..Goodlettville

select CONVERT(date, SaleDate) as SalesDate
from
MyPortfolio..Goodlettville


ALTER TABLE Goodlettville
ADD SalesDate DATE;

UPDATE Goodlettville
SET
SalesDate = CONVERT(date, SaleDate)

ALTER TABLE Goodlettville
DROP COLUMN SaleDate

select *
from
MyPortfolio..Goodlettville


-- Decouple Property Address Into PropertyStreet and PropertyCity for ease of determining best city to buy a house

select PropertyAddress, PARSENAME(REPLACE(PropertyAddress,',','.'), 2) AS StreetName,PARSENAME(REPLACE(PropertyAddress,',','.'), 1) AS City
from
MyPortfolio..Goodlettville

ALTER TABLE Goodlettville
ADD PropertyStreet nvarchar(255), PropertyCity nvarchar(255)

UPDATE Goodlettville
SET
PropertyStreet = PARSENAME(REPLACE(PropertyAddress,',','.'), 2),
PropertyCity = PARSENAME(REPLACE(PropertyAddress,',','.'), 1)

ALTER TABLE Goodlettville
DROP COLUMN PropertyAddress

select *
from 
MyPortfolio.dbo.Goodlettville

-- Decouple Owners Address into Street, City and State

Select OwnerAddress
from
MyPortfolio.dbo.Goodlettville

select OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as StreetName, 
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as StateCode
from
MyPortfolio.dbo.Goodlettville

ALTER TABLE Goodlettville
ADD OwnerStreet nvarchar(255), OwnerCity nvarchar(255), OwnerStateCode nvarchar(255)

UPDATE Goodlettville
SET
OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
OwnerStateCode = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

ALTER TABLE Goodlettville
DROP COLUMN OwnerAddress

select *
from
MyPortfolio..Goodlettville

-- DATA CONSISTENCY

Select distinct(SoldAsVacant), Count(SoldAsVacant)
from
MyPortfolio.dbo.Goodlettville
group by SoldAsVacant
order by 2


Select SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
ELSE SoldAsVacant
END
from
MyPortfolio.dbo.Goodlettville

UPDATE Goodlettville
SET
SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
ELSE SoldAsVacant
END

Select distinct(SoldAsVacant), Count(SoldAsVacant)
from
MyPortfolio.dbo.Goodlettville
group by SoldAsVacant
order by 2


-- REMOVE DUPLICATES
-- Determine Duplicate rows using either temp table or view

WITH DuplicateRow AS 
(
select * ,
			ROW_NUMBER() OVER (
			PARTITION BY ParcelID, PropertyStreet,
						 SalePrice, SalesDate, LegalReference
						 ORDER BY ParcelID
						 ) row_num
from
MyPortfolio..Goodlettville

)
delete
from
DuplicateRow
where row_num > 1


-- DATA Exploration
--Interest Made from each sale

select [UniqueID ], PropertyStreet, OwnerName, TotalValue, SalePrice, (SalePrice - TotalValue) As Profit
from
MyPortfolio.dbo.Goodlettville
order by Profit desc

-- Determining if the age of the property affects the price and profit

select [UniqueID ], PropertyStreet, OwnerName, YearBuilt, TotalValue, SalesDate, SalePrice, (SalePrice - TotalValue) As Profit,(YEAR(SalesDate) - YearBuilt) As PropertyAge
from
MyPortfolio.dbo.Goodlettville
Order by PropertyAge Desc

-- Determining if the Location of the property affects the price and profit
select [UniqueID ], PropertyStreet, PropertyCity,TotalValue,SalePrice, (SalePrice - TotalValue) As Profit
from
MyPortfolio.dbo.Goodlettville
Order by Profit Desc

-- Determining if the number of bedrom and bathroom of the property affects the price and profit

select [UniqueID ], Bedrooms, FullBath,TotalValue,SalePrice, (SalePrice - TotalValue) As Profit
from
MyPortfolio.dbo.Goodlettville
where Bedrooms is not null and FullBath is not null
Order by Profit Desc

-- Landlords who sold the house where they currently live   - Probability of sales due to Financial crunch

select [UniqueID ], OwnerName,TotalValue,SalePrice, (SalePrice - TotalValue) As Profit
from
MyPortfolio.dbo.Goodlettville
where PropertyStreet = OwnerStreet and PropertyCity = OwnerCity
Order by Profit Desc

select *
from
MyPortfolio.dbo.Goodlettville