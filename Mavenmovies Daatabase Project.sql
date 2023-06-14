use mavenmovies;

#1) write a sql query to count the number of characters except the spaces for each actor .
#Return first 10 actors name length along with their names

select * from actor ;

select fname , last_name, length(concat(fname,last_name)) as Name_Length from actor 
limit 10 ;

# here we dont have spaces between the names but what if the data is added to the table having spaces 
# so we have to make a dynamic query so that in future if names like ( fname =sushant and lname = singh rajput)
# having space between them are added then also we should get the proper output 
# so below is dynamic query for that 

select concat(fname ,' ', last_name), length(replace(concat(fname,last_name),' ','')) as Name_Length from actor 
limit 10 ;

# in above query i have replaces space with no space so the query will conct names then replace spaces with 
# np spaces if there are any and then gives the length

#2) List all oscar awardees ( actors who received oscar award) with their full names and length of their names


select first_name,last_name ,length(concat(first_name,last_name)) as Name_length ,awards from actor_award
where awards='oscar' ;

#or 


select concat(first_name,' ',last_name) as Actor_Name ,length(concat(first_name,last_name)) as Name_length,awards from actor_award
where awards='oscar'
order by Name_length ; #--> sir asked to sort it by name length 

# the below query is right one

select concat(first_name,' ',last_name) as Actor_Name ,length(concat(first_name,last_name)) as Name_length,awards from actor_award
where awards like '%oscar%' ;


#3)find the actors who have acted in the film frost head
#we will use actor ,film ,film_actor tables to make a join

select * from actor ;
select * from film ;
select * from film_actor ;

select a.actor_id,fname,last_name,title from actor as a 
inner join film_actor as fa
on a.actor_id=fa.actor_id
inner join film as f
on f.film_id=fa.film_id
where title='frost head';


#4)pull all the films acted by the actor will wilson
# we will use actor , film_actor and film tables to create a join 

select * from actor ;
select * from film_actor ;
select * from film ;


select fname,last_name ,title from actor as a 
inner join film_actor as fa
on a.actor_id=fa.actor_id
inner join film as f
on f.film_id=fa.film_id
where fname='will' and last_name='wilson'  ;

#5)pull all the films which were rented and returned in the month of may
# we will use rental ,film_text and inventory tables to make a join

select * from rental ;
select * from film_text ;
select * from inventory ;

select r.rental_id,r.rental_date,r.return_date,ft.film_id,ft.title from rental as r
inner join inventory as i
on r.inventory_id=i.inventory_id
inner join film_text as ft
on ft.film_id=i.film_id
where month(rental_date)= 5 and month(return_date)=5 ;

#or  if we want all details then execute below query 

select * from rental as r
inner join inventory as i
on r.inventory_id=i.inventory_id
inner join film_text as ft
on ft.film_id=i.film_id
where month(rental_date)= 5 and month(return_date)=5 ;

#6) pull all the films with comedy category
# we will use category , film and film_category tables to create a join 

select * from category ;
select * from film ;
select * from film_category ;

select name,title from category as c
inner join film_category as fc
on c.category_id=fc.category_id
inner join film as f
on f.film_id=fc.film_id
where name='comedy' ;


