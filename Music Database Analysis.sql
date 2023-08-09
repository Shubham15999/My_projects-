use sqlportfolio;

select * from album2 ;
select * from artist ;
select * from customer ;
select * from employee;
select * from genre ;
select * from invoice ;
select * from invoice_line ;
select * from media_type ;
select * from playlist;
select * from playlist_track ;
select * from track ;

#Q1 Who is the senior most employee based on job title  ?

select * from employee;


select * from employee 
order by levels desc;

# Q2 Which countries have the most invoices ?
select * from invoice ;

select billing_country , count(*) as Total_Invoices from invoice 
group by billing_country 
order by count(*) desc ;

# Q3 which  are the  top 3 countries which has highest number  of total invoices 

## For this one first if i assumed that no country has same number of invoices then I can first find the total invoice of each country 
# Then I will order it by desc of total count and limit it upto 3 .

select billing_country , count(*) as Total_Invoices from invoice 
group by billing_country 
order by count(*) desc 
limit 3 ;

# Now suppose there might be countries which have same number of invoices , in this case I will use dense rank function to
# include all the countries which have same total

with info as (select billing_country , count(*) as Total_Invoices , dense_rank() over ( order by count(*) desc) as ranks  from invoice 
group by billing_country )
select billing_country , Total_Invoices from info 
where ranks <= 3 ;

# Q3 what are top 3 values of total invoices 

select total from invoice 
order by total desc 
limit 3 ;

# OR 

select * from invoice
order by total desc  ;
select distinct total from (select total , dense_rank() over (order by total desc) as ranks from invoice) as t1
 where ranks <=3 ;
 
 # Q4 Which city has the best customers ? We would like to throw a promotional music festival in the city we made the most money 
 # Write a query that returns one city that has the highest sum of invoice totals . Return both city name & sum of all invoices .
 
 select * from invoice ;
 
 select billing_city , sum(total) as total_amt from invoice 
 group by billing_city 
 order by total_amt desc ;
 
 # Q5 Who is the best customer ? The customer who has spent the most money will be declared the best customer . 
 # write a query that returns the person who has spent the most money . 
 
 select * from customer ;
 select * from invoice ;
 
 # Info cte will give us the customer who has spent more amount after joining the invoice and customer table and then using 
 # group by and aggregate function sum 
 # nest we will join the info table with customer to get the customer name as well
 
 with info as  (select i.customer_id  , sum(total) as money_spent from customer as c 
 inner join invoice as i 
 on c.customer_id = i.customer_id 
 group by i.customer_id 
 order by money_spent desc
 limit 1 ) 
 select concat(first_name ," " ,  c.last_name) as Cust_name , i.money_spent from customer as c 
 inner join  info as i 
 on c.customer_id = i.customer_id ;
 
 # Question set 2 Moderate level 
 
 # Q1 Write a query to return the email , first name , last name and the genre of all Rock music listeners . 
 # Return your list ordered alphabetically by email starting with A 
 
 select * from customer ;
 select * from genre ;
 select * from track ; 
 select * from invoice;
 select * from invoice_line ;
 
 
 select distinct c.email , c.first_name, c.last_name   from genre as g 
 inner join track as t 
 on g.genre_id = t.genre_id
 inner join invoice_line as il 
 on il.track_id = t.track_id
 inner join invoice as i on 
 i.invoice_id = il.invoice_id
 inner join customer as c 
 on c.customer_id = i.customer_id
 where g.name = 'Rock'
 order by c.email ;
 
 
 # Q2 Let's invite the artists who have written the most rock music in our dataset . write a query that returns the artist
 # name and total track count of the top 10 rock bands .
 select * from artist ;
 select * from genre ;
 
 with info as (select a.artist_id, count(*) as Track_Count   from artist  as a 
 inner join album2 as al 
 on a.artist_id = al.artist_id
 inner join track as t 
 on t.album_id = al.album_id
 where genre_id in (select genre_id from genre where name = 'Rock')
 group by a.artist_id ) 
 select  a.name , i.track_count from info as i 
 inner join artist as a 
 on a.artist_id = i.artist_id 
 order by track_count desc
 limit 10 ;
 
 # Q3 Return all the track names that have a song length longer than the average song length . Return the name and milliseconds 
 # for each track .Order by the song length with longest song listed first .
 
 select  name  , milliseconds  from track 
 where milliseconds > (select avg(milliseconds) from track ) 
 order by milliseconds desc ;
 
 ## Question Set 3 Advanced 
 
 # Q1 Find how much amount spent by each customer on artists ? write a query to return customer name , artist name and 
 # Total spent 
 
 select * from customer ;
 
 
 with best_selling_artist as (select a.artist_id , a.name , sum(il.unit_price * il.quantity ) as total_sales 
 from invoice_line as il 
 inner join track  as t 
 on t.track_id = il.track_id 
 inner join album2 as al 
 on al.album_id = t.album_id
 inner join artist as a 
 on a.artist_id = al.artist_id 
 group by a.artist_id 
 order by total_sales desc)
 select c.customer_id ,c.first_name ,c.last_name , bsa.name , sum(il.unit_price * il.quantity ) as amount_spent
 from invoice as i 
 inner join customer as c
 on c.customer_id = i.customer_id
 inner join invoice_line as il 
 on il.invoice_id = i.invoice_id
 inner join track as t 
 on t.track_id = il.track_id
 inner join album2 as a 
 on a.album_id = t.album_id
 inner join best_selling_artist as bsa 
 on bsa.artist_id = a.artist_id 
 group by  c.customer_id ,c.first_name ,c.last_name , bsa.name
 order by sum(il.unit_price * il.quantity ) desc ;
 
 ## Q2 We want to find out the most popular music genre for each country . We determine the most popular genre as the genre
 # with the highest amount of purchases . Write a query that returns each country along with the top genre . 
 # For countries where the maximum number of purchases is shared return all genre

with popular_genre as ( 
select count(il.quantity ) as purchases ,c.country,g.name ,g.genre_id  , row_number() over(partition by c.country order by
 count(il.quantity)) as nos 
from invoice_line as il 
inner join invoice as i 
on i.invoice_id = il.invoice_id 
inner join customer as c 
on c.customer_id = i.customer_id 
inner join track as t 
on t.track_id = il.track_id 
inner join genre as g 
on g.genre_id = t.genre_id 
group by c.country,g.name ,g.genre_id
order by c.country, purchases desc) 
select * from popular_genre where nos = 1 ;


#Q3 Write a query that determines the customer that has spent the most on music for each country . Wrte a query that returns 
# country along with the top customer and how much they spent .For countries where the amount spent is shared , provide all
# customers who spent this amount 

with info as (select c.customer_id , first_name , last_name , country , sum(unit_price * quantity) as spent  , dense_rank()  over
 ( partition by country  order by  sum(unit_price * quantity) desc) as rnk 
 from customer as c 
inner join invoice as i 
on c.customer_id = i.customer_id 
inner join invoice_line as il 
on il.invoice_id = i.invoice_id
group by country , customer_id )
select country , spent , first_name , last_name , customer_id from info where rnk = 1