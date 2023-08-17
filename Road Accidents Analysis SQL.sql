use [Road Accident];


select * from road_accident;

--To find the total number of accidents in year 2022

select count(distinct accident_index) as CY_Accidents_Count from road_accident
where YEAR(accident_date) = '2022' ;


-- 1 Total Accidents:

--How many accidents occurred in each year (2021 and 2022)?
--current year casualties i.e for year 2022 as we have data for years 2021 to 2022

select  sum(number_of_casualties) as CY_Casualties  from road_accident
where YEAR(accident_date) = '2022' ;

select  sum(number_of_casualties) as PY_Casualties  from road_accident
where YEAR(accident_date) = '2021' ;

--What is the total number of accidents for both years combined?

select  sum(number_of_casualties) as PY_Casualties  from road_accident ;

-- 2 Monthly Accident Trends:
--month wise number of casualties 

-- For  year 2022
select datename(month,accident_date ) as Month_Name ,sum(number_of_casualties) as CY_casualties from road_accident
where YEAR(accident_date) = '2022'
group by datename(month,accident_date ) ;

--For year 2021

select datename(month,accident_date ) as Month_Name ,sum(number_of_casualties) as CY_casualties from road_accident
where YEAR(accident_date) = '2021'
group by datename(month,accident_date ) ;

-- Now I will find the change in the road accident percentage between 2021 and 2022
-- The formula for that is  YoY % change = (value in year 2 - value in year 1)/(value in year 1) * 100

with info1 as (
    select sum(number_of_casualties) as CY_Casualties  
    from road_accident
    where YEAR(accident_date) = '2022'
),
info2 as (
    select sum(number_of_casualties) as PY_Casualties  
    from road_accident
    where YEAR(accident_date) = '2021'
)
select CAST(ROUND(((cast(CY_Casualties - PY_Casualties as decimal) / CY_Casualties) * 100), 2) AS DECIMAL(10, 2))
as PercentageChange from info1, info2;


-- How did the number of accidents vary on a monthly basis in each year?


with info1 as (select datename(month,accident_date ) as Month_Name ,sum(number_of_casualties) as CY_casualties from road_accident
where YEAR(accident_date) = '2022'
group by datename(month,accident_date )),


info2 as (select datename(month,accident_date ) as Month_Name ,sum(number_of_casualties) as PY_casualties from road_accident
where YEAR(accident_date) = '2021'
group by datename(month,accident_date ) )

select i1.Month_name , i1.CY_casualties ,i2.PY_casualties , 
( CY_casualties - PY_casualties) * 100 / (PY_casualties) as PCT_Change
from info1 as i1 
inner join info2 as i2 
on i1.Month_Name = i2.Month_Name 
order by i1.CY_casualties;

--3 Accident Severity Analysis:
--What is the distribution of accident severities (fatal, serious, slight) for each year?
--Did the proportion of different accident severities change between the two years?
--TO find the total casualties by accident severity in year 2022

with info as (select accident_severity , sum(number_of_casualties) as CY_Casualties 
from road_accident
where YEAR(accident_date) = '2022'
group by accident_severity) ,
info1 as ( (SELECT CAST(SUM(number_of_casualties) AS DECIMAL) as total  
FROM road_accident WHERE YEAR(accident_date) = '2022'))
select accident_severity ,(CAST(CY_Casualties AS DECIMAL) / (select total from info1 )  * 100.0) AS Percentage
from info ;

-- similarly we can find for year 2021 and the change in percentage is almost same 





-- 4 Weather and Road Conditions:
--Which weather conditions were most commonly associated with accidents?
--What were the prevalent road surface conditions during accidents?
-- casualties based on weather conditions 

--Now we will find the total casualties for each road surface condition in year 2022

select road_surface_conditions ,sum(number_of_casualties) as CY_Casualties from road_accident
where YEAR(accident_date) = '2022'
group by road_surface_conditions ;

-- Casualties By Road Type 

select road_type , sum(number_of_casualties) as CY_Casualties from road_accident
where YEAR(accident_date) = '2022' 
group by road_type ;

with info1 as (select weather_conditions , sum(number_of_casualties) as PY_Casualties  from road_accident
where YEAR(accident_date) = '2021'
group by weather_conditions),

info2 as (select weather_conditions , sum(number_of_casualties) as CY_Casualties  from road_accident
where YEAR(accident_date) = '2022'
group by weather_conditions )
select i1.weather_conditions ,PY_Casualties, CY_Casualties from info1 as i1 
inner join info2 as i2 
on i1.weather_conditions = i2.weather_conditions
order by PY_Casualties desc ;


-- Highest Numner of Casualties based on combination of weather and road conditions

select Top 10 weather_conditions , road_surface_conditions, sum(number_of_casualties) as Total 
from road_accident
group by weather_conditions , road_surface_conditions
order by Total desc;


--5 Day of the Week Analysis:
--On which days of the week did accidents occur most frequently in each year?
--Was there any significant difference in accident occurrence on weekends vs. weekdays?
-- On which days of the week did accidents occur most frequently in each year?
select * from road_accident;

select  day_of_week  , sum(number_of_casualties) as Total  from road_accident
group by day_of_week 
order by Total desc ;


-- for each year 
with info1 as (select  day_of_week  , sum(number_of_casualties) as PY_Casualties  from road_accident
where year(accident_date) = '2021'
group by day_of_week ),
info2 as (select  day_of_week  , sum(number_of_casualties) as CY_Casualties  from road_accident
where year(accident_date) = '2022'
group by day_of_week)
select i1.day_of_week , PY_Casualties , CY_Casualties from info1 as i1
inner join info2 as i2 
on i1.day_of_week = i2.day_of_week
order by PY_Casualties desc  ;


--Was there any significant difference in accident occurrence on weekends vs. weekdays?

select sum(case when day_of_week in ('Friday' ,'Saturday' ,'Sunday') then 1 else 0   end ) as Weekend ,
sum(case when day_of_week not in ('Friday' ,'Saturday' ,'Sunday') then 1 else 0   end ) as Weekdays 
from road_accident  ; 

--6 Speed Limit Impact:
--Did accidents with higher speed limits tend to result in more severe outcomes?
--How did the distribution of speed limits differ between the two years?
-- casualties by speed limit
select * from road_accident;

select  speed_limit , sum(number_of_casualties) as Total  from road_accident
group by speed_limit
order by Total desc;

-- On yearly basis what were the number of casualties depending on speed limit 
select  speed_limit , sum(number_of_casualties) as Total  from road_accident
where YEAR(accident_date) = '2021'
group by speed_limit
order by Total desc;

select  speed_limit , sum(number_of_casualties) as Total  from road_accident
where YEAR(accident_date) = '2022'
group by speed_limit
order by Total desc;

-- Did accidents with higher speed limits tend to result in more severe outcomes?
-- The cte info provides the rquires answer but for better visualization I have used Pivot table so that we
-- can compare it easily

with info as (select  speed_limit , accident_severity , sum(number_of_casualties) as Total  from road_accident
where YEAR(accident_date) = '2021' 
group by speed_limit , accident_severity)
select accident_severity , max( case when speed_limit = 30 then Total end ) as '30',
max( case when speed_limit = 60 then Total end ) as '60',
max( case when speed_limit = 40 then Total end ) as '40',
max( case when speed_limit = 70 then Total end ) as '70',
max( case when speed_limit = 50 then Total end ) as '50',
max( case when speed_limit = 20 then Total end ) as '20',
max( case when speed_limit = 10 then Total end ) as '10',
max( case when speed_limit = 15 then Total end ) as '15'
from info
group by accident_severity ;


--7. Urban vs. Rural Accidents:
--Were accidents more common in urban or rural areas in each year?
--Did the urban-rural distribution change over the two years?
-- Casualties %  by area

select urban_or_rural_area, cast(cast(sum(number_of_casualties) as decimal (10,2)) * 100  /
(select  cast(sum(number_of_casualties) as decimal (10,2)) from  road_accident where YEAR(accident_date) = '2022' ) 
as decimal (10,2))
as PCT from road_accident
where YEAR(accident_date) = '2022'
group by urban_or_rural_area ;


-- Top 10 Locations by No of  Casualties 

select Top 10 local_authority , sum(number_of_casualties) as  Total_Casualties from road_accident
group by local_authority
order by Total_Casualties Desc 

--8.Time-of-Day Analysis:
--At what times of the day did accidents occur most often?
--Were there any shifts in the time distribution of accidents between the two years?
select * from road_accident;

SELECT
    DATEPART(HOUR, time) AS HourOfDay,
    COUNT(*) AS TotalAccidents
FROM road_accident
WHERE YEAR(accident_date) IN (2021, 2022)
GROUP BY DATEPART(HOUR, time)
ORDER BY TotalAccidents DESC;



--9.Vehicle Type Involvement:
--Which types of vehicles were frequently involved in accidents?
--Did the proportion of vehicle types change over the two years?

-- Now to find the casualties by vehicle type 

-- select distinct vehicle_type  from road_accident 
-- First found the distinct different types of vehicle and then categorize them based on following conditions
-- in cte info using case statements .

with info as (select number_of_casualties , case 
when vehicle_type in('Agricultural vehicle') then 'Agricultural'
when vehicle_type in ('car' , 'Taxi/Private hire car') then 'Car'
when vehicle_type in ('Bus or coach (17 or more pass seats)','Minibus (8 - 16 passenger seats)') then 'Bus'
when vehicle_type in ('Goods 7.5 tonnes mgw and over','Goods over 3.5t. and under 7.5t',
'Van / Goods 3.5 tonnes mgw or under') then 'Van'
when vehicle_type in ('Motorcycle 125cc and under','Motorcycle 50cc and under','Motorcycle over 125cc and up to 500cc',
'Motorcycle over 500cc','Pedal cycle') then 'Bike'
ELSE 'Other' 
end as 'Type_of_vehicle'
from road_accident
where YEAR(accident_date) = '2022')
select Type_of_vehicle , sum(number_of_casualties) as CY_Casualties from info 
group by Type_of_vehicle ;

























