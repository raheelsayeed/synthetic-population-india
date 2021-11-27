//

select r.name, r.code, r.level, r.level3_code, (select name from Regions where code = r.level3_code) SbD,  p.total from Population p Join Regions r ON r.code = p.region_code limit 40;



select r.name TownOrVillage, r.code, 
(select name from Regions where code = r.level3_code) SubDistrict,
(select name from Regions where code = r.level2_code) District,
p.total TotalPop,
p.males TotalMalePop,
p.females TotalFemalePop,
sum(p.total) OverAll
from Population p Join Regions r on r.code = p.region_code 
where p.level3_code = 532 AND level


### Villages 
select * from Regions where level = 4 and level3_code = 4305;


select r.code, r.name TownVillage,
(select name from Regions where code = r.level3_code) SubDistrict,
(select name from Regions where code = r.level2_code) District,
p.total 'Population',
sum(p.total) 'TotalPopulation'
from Regions r Join Population p on p.region_code = r.code
where r.level3_code = 4305


### Population For Districts(s) and Subdistricts(s)

select r.code, r.name TownVillage,
(select name from Regions where code = r.level3_code) SubDistrict,
(select name from Regions where code = r.level2_code) District,
p.total 'Population'
from Regions r Join Population p on p.region_code = r.code
where r.level2_code = 


### Total Populations For Subdistrict(s) or District(s)

select r.code, r.name TownVillage,
(select name from Regions where code = r.level3_code) SubDistrict,
(select name from Regions where code = r.level2_code) District,
p.total 'Population',
sum(p.total) 'TotalPopulation',
avg(p.total) 'AvgPopulation'
from Regions r Join Population p on p.region_code = r.code
where r.level3_code = 

### Population of All Subdistricts (...,...,...)

Select  (select name from Region where code = r.subdistrictcode) as SubDistrict,  sum(p.total) SumTotalPop from Region r Left Join Population p on p.region_code = r.code  where r.subdistrictcode IN (4307, 4308, 4305)  group by SubDistrict

### Population of All Subdistricts in a District 

Select  count(1) as Regions , (select name from Region where code = r.subdistrictcode) as SubDistrict,   sum(p.total) SumTotalPop, (select name from Region where code = r.districtcode) District  from Region r Left Join Population p on p.region_code = r.code  where r.level = 4 and  r.subdistrictcode IN (select code from Region where districtcode IN (536))  group by SubDistrict order by r.districtcode;


### Population of All Subdistrict(s) In a specified ===== District(s)

Select  count(1) as Regions , (select name from Region where code = r.subdistrictcode) as SubDistrict,   sum(p.total) SumTotalPop, round(avg(p.total),1) AveragePop_TV, (select name from Region where code = r.districtcode) District  from Region r Left Join Population p on p.region_code = r.code  where r.level = 4 and  r.subdistrictcode IN (select code from Region where districtcode IN (532,533))  group by SubDistrict order by r.subdistrictcode

### Change the Group By to District for aggregate Totals of District.


Select  count(1) as Regions , (select name from Region where code = r.subdistrictcode) as SubDistrict,   sum(p.total) SumTotalPop, (select name from Region where code = r.districtcode) District  from Region r Left Join Population p on p.region_code = r.code  where r.level = 4 and  r.subdistrictcode IN (select code from Region where districtcode IN (532,533))  group by District order by r.subdistrictcode

### Combine Households and Population | Change Group By to "Subdistrict" or "District"


Select count(1) as Regions, 
    (select name from Region where code = r.subdistrictcode) SubDistrict,
    sum(p.total) Sum_TotalPopulation,
    round(avg(p.total),1) AvgPop_TV,
    sum(h.total) Sum_TotalHouseholds,
    sum(h.size_mean) HH_Size_mean,
    round(avg(h.total),1) AvgHH_TV,
    (select name from Region where code = r.districtcode) District
FROM
    Region r
        LEFT JOIN Population p ON p.region_code = r.code
        LEFT JOIN Household h ON h.region_code = r.code
WHERE
    r.level = 4 AND r.subdistrictcode IN (select code from Region where districtcode IN (532, 533))
GROUP BY
    SubDistrict
ORDER BY
    r.subdistrictcode

### Households by Distribution

Select count(1) as Regions, 
    (select name from Region where code = r.subdistrictcode) SubDistrict,
    sum(p.total) Sum_TotalPopulation,
    round(avg(p.total),1) AvgPop_TV,
    sum(h.total) Sum_TotalHouseholds,
    sum(h.size_mean) HH_Size_mean,
    round(avg(h.total),1) AvgHH_TV,
    (select name from Region where code = r.districtcode) District
FROM
    Region r
        LEFT JOIN Population p ON p.region_code = r.code
        LEFT JOIN Household h ON h.region_code = r.code
WHERE
    r.level = 3 AND r.districtcode IN (532, 533)
GROUP BY
    District
ORDER BY
    r.subdistrictcode






### District Area
### SubDistrict Area
### Village Area
### Town Area
### Population Density