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


### Population For Districts(s)

select r.code, r.name TownVillage,
(select name from Regions where code = r.level3_code) SubDistrict,
(select name from Regions where code = r.level2_code) District,
p.total 'Population'
from Regions r Join Population p on p.region_code = r.code
where r.level2_code = 


### Populations For Subdistrict(s) or District(s)

select r.code, r.name TownVillage,
(select name from Regions where code = r.level3_code) SubDistrict,
(select name from Regions where code = r.level2_code) District,
p.total 'Population',
sum(p.total) 'TotalPopulation',
avg(p.total) 'AvgPopulation'
from Regions r Join Population p on p.region_code = r.code
where r.level3_code = 


==================================


# Workers

 - Workers {Total, Total Male, Total Female}
 - Aggregate Workers{} by State (level=1), District (level=2), Subdistrict (level=3), Village or Town (level=4)

### Workers by SubDistrict 

 - List  'select r.name as 'Vill/Town',r.code, r.level, case when r.type=1 then 'Rural' else 'Urban' end as Type, w.total TotalWorkers from Workers w join Region r on w.region_code = r.code WHERE r.subdistrictcode = 4306'
 - Total 'select (select name from Region where code = r.subdistrictcode) SubDistrict, sum(w.total) TotalWorkers from Workers w join Region r on w.region_code = r.code WHERE r.subdistrictcode = 4306'

### Workers By District

 - List  'select r.name as 'Vill/Town',r.code, r.level, case when r.type=1 then 'Rural' else 'Urban' end as Type, w.total TotalWorkers from Workers w join Region r on w.region_code = r.code WHERE r.districtcode = 532'
 - Total 'select (select name from Region where code = r.districtcode) District, sum(w.total) TotalWorkers from Workers w join Region r on w.region_code = r.code WHERE r.districtcode = 532'

#### Listings: 

Vill/Town    code        level       Type        TotalWorkers
-----------  ----------  ----------  ----------  ------------
Karanji (T)  568945      4           Rural       1379        
Guledi       568946      4           Rural       375         
Gomutri      568947      4           Rural       665         
Antargaon    568948      4           Rural       559         
Arli (T)     568949      4           Rural       1787        
Wadoor       568950      4           Rural       697         
Dhanora      568951      4           Rural       578         
Kamathwada   568952      4           Rural       182         
Gona         568953      4           Rural       240         
Gunjala      568954      4           Rural       481         
Gollaghat    568955      4           Rural       172         
Tamsi (K)    568956      4           Rural       581         
Nipani       568957      4           Rural       872         
Dabbakuchi   568958      4           Rural       228         
Bheempoor    568959      4           Rural       1002        
Belsari Ram  568960      4           Rural       668         
Anderband    568961      4           Rural       869         
Girgaon      568962      4           Rural       561         
Ambugaon     568963      4           Rural       208         
Palodi (Ram  568964      4           Rural       184


#### Aggregates

District     TotalWorkers
----------   ------------
Adilabad     1146589

SubDistrict  TotalWorkers
-----------  ------------
Tamsi        22826


----------------------------


# Population

- Population {Total, Total Male, Total Female}
- Population Workers{} by State (level=1), District (level=2), Subdistrict (level=3), Village or Town (level=4)

### Population by SubDistrict 

- List  'select r.name as 'Vill/Town',r.code, r.level, case when r.type=1 then 'Rural' else 'Urban' end as Type, p.total TotalPopulation from Population p join Region r on p.region_code = r.code WHERE r.subdistrictcode = 4306'
- Total 'select (select name from Region where code = r.subdistrictcode) SubDistrict, sum(p.total) TotalPopulation from Population p join Region r on p.region_code = r.code WHERE r.subdistrictcode = 4306'

### Population By District

-  List  'select r.name as 'Vill/Town', r.code, r.level, case when r.type=1 then 'Rural' else 'Urban' end as Type, p.total TotalPopulation from Population p join Region r on p.region_code = r.code WHERE r.districtcode = 532'
- Total 'select (select name from Region where code = r.districtcode) District, sum(p.total) TotalPopulation from Population p join Region r on p.region_code = r.code WHERE r.districtcode = 532'


# NEW

Population 
 
### List By Subdistrict

Select r.row_id, r.name as 'Village/Town', r.code, r.level, (select name from Region where code = r.subdistrictcode) as SubDistrict, case when r.type=1 then 'Rural' else 'Urban' end as Type, p.total TotalPopulation from Region r Left Join Population p on p.region_code = r.code  where r.subdistrictcode = 4306

### Aggregates of Subdistrict Population, add 'r.type' for rural and urban divide

Select (select name from Region where code = r.subdistrictcode) as SubDistrict,  sum(p.total) SumTotalPop from Region r Left Join Population p on p.region_code = r.code  where r.subdistrictcode = 4306


