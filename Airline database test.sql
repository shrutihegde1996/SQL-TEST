/* 
	SQL ASSIGNMENT QUESTIONS TO ANSWER
	The given data set has information regarding flight arrival and departure time given details about their airline company 
	and as well as airport details of origin and destination.
*/

/*
	1.	Find out the airline company which has a greater number of flight movement.
*/

select 
     c.carrier_code as Airline,
	 f.carrierid as Airline_Code,
	 count(flightid) as Count_Of_Flights
from flight_detail as f
   left join carrier_detail as c
      on f.carrierId = c.Carrier_ID
group by Airline , Airline_Code
order by Count_Of_Flights desc;

/*
	2.	Get the details of the first five flights that has high airtime.
*/

select 
      flightid,
      airtime
from flight_detail
order by airtime desc limit 5;

/*
	3.	Compute the maximum difference between the scheduled and actual arrival and departure time for the flights and 
    categorize it by the airline companies.
*/

select
       carrier_code,
       max(timediff( arrivaltime , scheduledarrivaltime )) as Arrival_Diff,
	   max(timediff(departuretime , scheduleddeparturetime )) as Departure_Diff
from flight_detail as f
   left join carrier_detail as c
      on f.carrierId = c.Carrier_ID
group by carrier_code
order by Arrival_Diff desc , Departure_Diff desc ;

/*
	4.	Find the month in which the flight delays happened to be more.
*/

select * from flight_detail limit 30;

select 
     flight_month,
     count(flightid) as Flights_Count
from flight_detail
where (arrivaldelay > 0) or (departuredelay > 0)
group by flight_month
order by Flights_Count desc ;

/*
	5.	Get the flight count for each state and identify the top 1.
*/

select 
      s.stateid,
      s.state_code,
      count(FlightId) as Flight_Count
from flight_detail as f
left join route_detail as r
    on f.routeId = r.route_ID
left join airport_detail as a
    on r.origincode = a.locationId
left join airport_detail as a1
    on r.destinationcode = a1.locationId
left join state_detail as s
    on a1.stateId = s.stateId
group by stateid, state_code
order by Flight_Count desc;

/*
	6.	 A customer wants to book a flight under an emergency situation. Which airline would you suggest him to book. Justify your answer.
*/

select 
      f.carrierid,
      carrier_code,
      count(flightid) as Flights_Count
from flight_detail as f
left join carrier_detail as c
    on f.carrierId = c.Carrier_ID
where arrivaldelay < 0 
group by  f.carrierid, Carrier_code;

/* "JUSTIFICATION" I would suggest the customer to book any of the WN airline flights because the more flights arrive before 
scheduled arrival time. */

/*
	7.	Find the dates in each month on which the flight delays are more.
*/

select 
     flight_date,
     flight_month,
	 count(flightid) as Flights_Count
from flight_detail
where (arrivaldelay > 0) or (departuredelay > 0) 
group by  flight_date,flight_month
order by Flights_Count desc;

/*
	8.	Calculate the percentage of flights that are delayed compared to flights that arrived on time.
*/

with flight_delayed as
 (
      select  
            flightid,
		    count(flightid) as Flight_Delayed_Count
	  from flight_detail
	  where arrivaldelay > 0 or departuredelay > 0
      group by flightid
)

, flight_arrived_ontime as
(
    select
        flightid,
		count(flightid) as Flight_Arrived_Ontime_Count
	from flight_detail
	where arrivaldelay = 0 
    group by flightid
)

select 
      a.Flight_Delayed_Count / count(f.FlightId) as Percentage_of_FlightDelay,
      b.Flight_Arrived_Ontime_Count / count(f.FlightId) as Percentage_of_FlightArrived_Ontime
from flight_detail as f
left join flight_delayed as a
     on f.flightid = a.flightid
left join flight_arrived_ontime as b
     on a.flightid = b.flightid	;

/*
	9.	Identify the routes that has more delay time.
*/

select 
      f.routeid,
	  a1.IATA_code as Origin,
      a2.IATA_code as Destination,
      arrivaldelay,
      departuredelay
from flight_detail as f
left join route_detail as r
    on f.routeid = r.route_id
 left join airport_detail as a1
    on r.origincode = a1.locationId
 left join airport_detail as a2
    on r.destinationcode = a2.locationId   
where arrivaldelay > 0 or departuredelay > 0
order by  arrivaldelay, departuredelay desc;

/*
	10.	Find out on which day of week the flight delays happen more.
*/

select 
      dayweek,
      count(FlightId) as Flights_Delayed_Count
from flight_detail 
where arrivaldelay > 0 or departuredelay > 0
group by dayweek
order by Flights_Delayed_Count desc ;

/*
	11.	Identify at which part of day flights arrive late.
*/

with flights_midnight as
(
    select 
          count(flightid) as Midnight_Flights_Count
	from flight_detail
    where (departuretime between '00:00:00' and '04:59:00') and (arrivaldelay > 0)
)

, flights_morning as
(
    select 
          count(flightid) as Morning_Flights_Count
	from flight_detail
    where (departuretime between '05:00:00' and '11:59:00') and (arrivaldelay > 0)
)

, flights_afternoon as
(
    select 
          count(flightid) as Afternoon_Flights_Count
	from flight_detail
    where (departuretime between '12:00:00' and '18:59:00') and (arrivaldelay > 0)
)

, flights_night as
(
    select 
          count(flightid) as Night_Flights_Count
	from flight_detail
    where (departuretime between '19:00:00' and '23:59:00') and (arrivaldelay > 0)
)

, total_flights as
(
    select
          count(flightid) as Total_Flights
	from flight_detail
)
select 
	  Midnight_Flights_Count/ Total_Flights as Percentage_Midnight_Delay ,
      Morning_Flights_Count / Total_Flights as Percentage_Morning_Delay,
	  Afternoon_Flights_Count / Total_Flights as Percentage_Afternoon_Delay,
     Night_Flights_Count / Total_Flights as Percentage_Night_Delay
from total_flights , flights_midnight , flights_morning, flights_afternoon , flights_night;

-- /* Justify ans: Flights arrive late more during afternoon.*/

/*
	12.	Compute the maximum, minimum and average TaxiIn and TaxiOut time.
*/

select 
      dayweek,
      max(taxiin) as Max_TaxiIn,
      max(taxiout) as Max_TaxiOut,
	  min(taxiin) as Min_TaxiIn,
      min(taxiout) as Min_TaxiOut,
	  avg(taxiin) as Avg_TaxiIn,
      avg(taxiout) as Avg_TaxiOut
from flight_detail
group by dayweek;

/*
	13.	Get the details of origin and destination with maximum flight movement.
*/

select
      r.route_ID,
      a1.IATA_code as origin,
      a2.IATA_code as destination,
	  count(flightid) as Flight_Movement
from flight_detail as f
left join route_detail as r
    on f.routeId = r.route_ID
left join airport_detail as a1
    on r.origincode = a1.locationId
left join airport_detail as a2
    on r.destinationcode = a2.locationId  
group by origincode, destinationcode
order by Flight_Movement desc;
       
/*
	14.	Find out which delay cause occurrence is maximum.
*/

select * from flight_detail limit 20;

with carrier_delay as
(
     select
           flight_date,
           count(FlightId) as CarrierCount
	from flight_detail
    where (arrivaldelay > 0 or departuredelay > 0) and (carrierdelay > 0)
    group by flight_date
)

, nas_delay as
(
     select
           flight_date,
           count(FlightId) as NASCount
	from flight_detail
    where (arrivaldelay > 0 or departuredelay > 0) and (nasdelay > 0)
    group by flight_date
)

, weather_delay as
(
     select
           flight_date,
           count(FlightId) as WeatherCount
	from flight_detail
    where (arrivaldelay > 0 or departuredelay > 0) and (weatherdelay > 0)
    group by flight_date
)

, security_delay as
(
     select
           flight_date,
           count(FlightId) as SecurityCount
	from flight_detail
    where (arrivaldelay > 0 or departuredelay > 0) and (securitydelay > 0)
    group by flight_date
)

select 
      f.flight_date,
      CarrierCount,
      NASCount,
      WeatherCount,
      SecurityCount
from flight_detail as f
left join carrier_delay as c
    on f.flight_date = c.flight_date
left join nas_delay as n
    on n.flight_date = c.flight_date
left join weather_delay as w
    on w.flight_date = n.flight_date
left join security_delay as s
    on s.flight_date = w.flight_date
group by flight_date;
      
/*
	15.	Get details of flight whose speed is between 400 to 600 miles/hr for each airline company.
*/
  
  with cte as
  (
     select
          flightid,
          airtime / 60 as Airtime_in_hours
	from flight_detail
)
  select
       f.flightid,
       f.carrierid,
       distance,
       cte.Airtime_in_hours,
       distance /Airtime_in_hours as Speed
from  cte 
left join  flight_detail as f
    on f.flightid = cte.flightid
left join  carrier_detail as c
    on f.carrierId = c.Carrier_ID
where (distance / Airtime_in_hours  between 400 and  600);
       
/*
	16.	Identify the best time in a day to book a flight for a customer to reduce the delay.
*/

select * from flight_detail limit 100;

with flights_midnight as
(
    select 
          count(flightid) as Midnight_Flights_Count
	from flight_detail
    where (departuretime between '00:00:00' and '04:59:00') and (arrivaldelay > 0 or departuredelay > 0)
)

, flights_morning as
(
    select 
          count(flightid) as Morning_Flights_Count
	from flight_detail
    where (departuretime between '05:00:00' and '11:59:00') and (arrivaldelay > 0 or departuredelay > 0)
)

, flights_afternoon as
(
    select 
          count(flightid) as Afternoon_Flights_Count
	from flight_detail
    where (departuretime between '12:00:00' and '18:59:00') and (arrivaldelay > 0 or departuredelay > 0)
)

, flights_night as
(
    select 
          count(flightid) as Night_Flights_Count
	from flight_detail
    where (departuretime between '19:00:00' and '23:59:00') and (arrivaldelay > 0 or departuredelay > 0)
)

select 
     Midnight_Flights_Count ,
     Morning_Flights_Count ,
     Afternoon_Flights_Count,
     Night_Flights_Count
from flights_midnight , flights_morning, flights_afternoon , flights_night;

-- Flights that are scheduled at midnight ( Timings between '00:00:00' and '04:59:00' ) have less delay. So it's 
 --  better to travel at midnight to experience less delays

/*
	17.	Get the route details with airline company code ‘AQ’
*/
select * from route_detail limit 100;
select * from carrier_detail limit 100;
  
select
      Carrier_code,
     carrierId,
     a1.IATA_code as origin,
      a2.IATA_code as destination
 from carrier_detail as c
   left join flight_detail as f
	 on c.carrier_id = f.carrierId
   left join route_detail as r
     on f.routeid = r.route_ID
   left join airport_detail as a1
     on  r.origincode = a1.locationId
   left join airport_detail as a2
     on r.destinationcode = a2.locationId
 where Carrier_ID = 17
 group by origin , destination;
   
/*
	18.	Identify on which dates in a year flight movement is large.
*/

select 
      flight_date,
      count(flightid)
from flight_detail
group by flight_date
order by count(flightid) desc;

/*
	19.	Find out which delay cause is occurring more for each airline company.
*/
select * from flight_detail limit 100;  
    
with delays_count as
(
    select 
          flightid,
          carrierid,
          count(case when cancellationcode = 'A' then flightid else null end ) as carrierdelay_count,
		  count(case when cancellationcode = 'B' then flightid else null end ) as weatherdelay_count,
		  count(case when cancellationcode = 'C' then flightid else null end ) as nasdelay_count,
		  count(case when cancellationcode = 'D' then flightid else null end ) as securitydelay_count
    from flight_detail 
    group by flightid
)

select
	flightid,
     carrierid,
	-- cancellationcode,
     carrierdelay_count,
     weatherdelay_count,
     nasdelay_count,
     securitydelay_count
from delays_count as d
left join carrier_detail as c
   on d.carrierId = c.Carrier_ID;
   
/*
	20.	 Write a query that represent your unique observation in the database.
*/

select 
      count(flightid) 
from flight_detail
where diverted = 1;