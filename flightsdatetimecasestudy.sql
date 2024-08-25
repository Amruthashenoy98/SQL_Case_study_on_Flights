use new_flights;
-- drop table flights;
select * from flights;

-- 1. Find the month with most number of flights
select monthname(Date_of_Journey) as 'Month' from flights group by monthname(Date_of_Journey) order by count(*) desc limit 1;

-- 2. Which weekday has most costly flights
select dayname(Date_of_Journey),avg(Price) from flights group by dayname(Date_of_Journey) order by avg(price) desc limit 1;

-- 3. Find no. of Indigo flights every month
select monthname(Date_of_Journey)as 'month',count(*) as 'No.of flights' from flights 
where Airline="IndiGo" group by monthname(Date_of_Journey) ;

-- 4. Find a list of all flights that depart between 10 AM and 2 PM from Delhi to Bangalore
select Airline,date_format(str_to_date(Dep_Time,"%k:%i"),'%l:%i %p') time_of_departure  from flights 
where date_format(str_to_date(Dep_Time,"%k:%i"),'%l:%i %p')
between str_to_date('10:00 AM','%l:%i %p') AND str_to_date('2:00 PM','%l:%i %p') 
and Source='Banglore' and Destination='Delhi';

-- 5. Find the number of flights departing on weekends from Bangalore
select count(*) as 'no of flights' from flights where Source='Banglore' and dayname(Date_of_Journey) in ('Saturday','Sunday');

-- 6. Calculate the arrival time for all flights by adding the duration to the departure time.
select * from flights;
/*alter table flights
add column departure_time datetime,
add column duration_mins INTEGER,
add column arrival_time DATETIME;*/

update flights
set departure_time = str_to_date(concat_ws(' ',Date_of_Journey,Dep_Time),'%Y-%m-%d %k:%i'),
duration_mins = cast(substring_index(Duration,'h',1) as decimal) * 60 + 
case when cast(replace(substring_index(Duration,' ',-1),'m','') as char)=substring_index(Duration,' ',-1) then 0
else replace(substring_index(Duration,' ',-1),'m','') end ,
arrival_time = date_add(departure_time, interval duration_mins MINUTE) ;

-- 7. Calculate the arrival date for all the flights
select date(arrival_time) as arrival_date from flights;

-- 8. Calculate the average duration of flights between all city pairs.
select source,destination, avg(duration_mins) from flights  group by source,destination;
-- 9. Find all flights which departed before midnight but arrived at their destination after midnight having only 1 stop.
select * from flights where date(departure_time)<date(arrival_time) and Total_Stops='1 Stop';

-- 10. Find quarter-wise number of flights for each airline
select Airline,Quarter(Date_of_Journey),count(*) from flights group by Airline,quarter(Date_of_Journey);

-- 12. Find the longest flight distance (between cities in terms of time) in India
select Source,Destination, max(duration_mins) from flights group by Source,Destination;

-- 13. Average time duration for flights that have 1 stop vs more than 1 stops
select avg(duration_mins) as 'avg_duration_1stop' ,(select avg(duration_mins) from flights where Total_Stops>1)
as 'avg_duration_more_than_1stop' from flights where Total_Stops=1;

-- 14. Find all Air India flights in a given date range originating from Delhi
select * from flights where Airline='Air India' and Source='Delhi' and 
str_to_date(Date_of_Journey,'%Y-%m-%d') between '2019-01-03' and '2019-01-21';

-- 15. Find the longest flight of each airline
select airline,max(duration_mins) from flights group by airline;

-- 16. Find all the pair of cities having average time duration > 3 hours
select Source, Destination, sec_to_time(avg(duration_mins)*60) from flights 
group by Source, Destination
having sec_to_time(avg(duration_mins)*60)>'03:00:00';

-- 17. Make a weekday vs time grid showing the frequency of flights from Bangalore and Delhi
select dayname(departure_time) as DayName, sum(case when hour(departure_time) between 0 and 5 then 1 else 0 end )as '12 AM-6 AM' ,
sum(case when hour(departure_time) between 6 and 11 then 1 else 0 end) as '6 AM-12 PM' ,
sum(case when hour(departure_time) between 12 and 17 then 1 else 0 end) as '12 PM-6 PM' ,
sum(case when hour(departure_time) between 18 and 23 then 1 else 0 end) as '6 PM-12 AM' 
from flights where source='Banglore' and destination='delhi'
group by dayofweek(departure_time),dayname(departure_time)
order by dayofweek(departure_time);

-- SELECT @@sql_mode;
-- SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));


-- 18. Make a weekday vs time grid showing average flight price from Bangalore and Delhi
select dayname(departure_time) as DayName, avg(case when hour(departure_time) between 0 and 5 then Price else 0 end )as '12 AM-6 AM' ,
avg(case when hour(departure_time) between 6 and 11 then Price else 0 end) as '6 AM-12 PM' ,
avg(case when hour(departure_time) between 12 and 17 then Price else 0 end) as '12 PM-6 PM' ,
avg(case when hour(departure_time) between 18 and 23 then Price else 0 end) as '6 PM-12 AM' 
from flights where source='Banglore' and destination='delhi'
group by dayofweek(departure_time),dayname(departure_time)
order by dayofweek(departure_time);

-- 19. Fetch city names
SELECT DISTINCT(Destination) as 'cities' FROM flights
UNION
SELECT DISTINCT(Source) FROM flights;
       
-- 20. Fetch frequency of flights of each Airline    
SELECT Airline,COUNT(*) as 'No. of flights' FROM flights
GROUP BY Airline;

-- 21. Fetch the city which has most busy airport
SELECT Source,COUNT(*) as 'No. of flights' FROM (SELECT Source FROM flights
							UNION ALL
							SELECT Destination FROM flights) t
GROUP BY t.Source
ORDER BY COUNT(*) DESC LIMIT 1;
   


  
       

        

