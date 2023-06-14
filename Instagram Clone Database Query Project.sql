
use ig_clone ;

select * from comments ;  #( id,commnet text,photo id,user id ,created at)
select * from follows ; #( follower id,followee id ,created at)
select * from likes  ; #( user id , photo id,created at)
select * from photo_tags ; #( photo id, tag id)
select * from photos  ; #( id , image url,user id, created at)
select * from tags  ; #( id ,tag name,created at)
select * from users  ; #( id,username,created at)

# Q2 we want to reward the users who has been around the longest , Find 5 oldest users 

select * from users ;

select * from users order by created_at asc
limit 5 ;

#Q3 to understand when to run ad campaign ,figure out the day of the week most users registered on 

select * from users ;
select dayname(created_at) , count(*) daycount , dense_rank () over (order by daycount desc) as a from users 
group by dayname(created_at)
having daycount = max(a) ;


with info as (select dayname(created_at) as dayName1, count(*) as daycount   , dense_rank () over (order by count(*) desc) as a from users 
group by dayname(created_at) )
select dayName1,(daycount) from info 
where a =1 ;


select dayname(created_at) ,count(*) as max_users  from users group by dayname(created_at) 
# above query will give maximum users registered on each day . now to get a particular day having maximum users registered 
#so we will use cte  . we will write above query as cte . we have written a subquery next .so the inner query will get the 
# maximum number of days when users are registered i.e. 16 . then outer query will work . It will select dayname from cte 
# and max_users from cte where we have number of days is equal to 16 .so our output will be thursday and sunday

with days_name as (select dayname(created_at) as highest_days ,count(*) as max_users  from users group by dayname(created_at))
select highest_days ,max_users from days_name where max_users in (select max(max_users) from days_name ) ;



# Q4 to target inactive users in an email ad campaign ,find users who have never posted a photo
select * from users ;
select * from photos ;



select id ,username from users where id not in (select distinct(user_id) from photos) ;



#Q5 suppose you are running a contest to find out who got most likes on photo . Find out who won 
select * from likes ;    #( likes tables means user id 1 has liked photo id 1 like that)
select * from users ;
select * from photos ;


with most_liked as (select photo_id ,count(user_id) as max_likes from likes  l group by photo_id )
select u.id, u.username from users as u 
inner join photos as p 
on u.id=p.user_id 
where p.id in 
(select photo_id from most_liked where max_likes =(select max(max_likes) from most_liked)) ;

# in this query i have first created cte named as most_liked which will give us photo id and their respective likes count 
# next i have created a join using users table and photos table as they have user_id common .
# subquery at line 65 returns photo_id from most_liked where max_liked is equal to the maximum of max_likes i.e. maximum likes
# from most_liked 

#Q6 the investor want to know how many times does the average user posts 
select * from users ;
select * from photos ;

with avg_photo_count as (select user_id,count(id) as no_of_photo from photos group by user_id )
select avg(no_of_photo) from avg_photo_count ;

# so here i have created a cte as avg_photo_count which will give user id and their respective count of photos posted 
#the query at line 77 will return average users  post 

#Q7 a brand wants to know which hashtag to use on a post and find top 5 most used hashtags
select * from photo_tags ;  #21
 select * from tags ;
 
 with info as (select tag_id ,count(*) as tagcount , dense_rank () over (order by count(*) desc ) as a from photo_tags 
 group by tag_id)
 select id , tag_name , i.tagcount from tags as t
 inner join info as i
 on t.id = i.tag_id
 where a<= 5 
 order by a asc ;
 
with most_used as (select tag_name, count(tag_id) as hashtags, dense_rank() over (order by count(tag_id) desc) as a
 from tags as t
join photo_tags as pt
on pt.tag_id=t.id
group by tag_id
)
select tag_name,hashtags from most_used 
where a<=5 ;
 
# inner query will give tags and their respective ordered by hashtags in descending order .
# the dense_rank() function will assigh rank to the result set
# query from line 100 will give top 5  tag name and their count  count 
# here we used dense rank function as the count of hastags for  food ,lol and concert is same .so if go by traditional 
# method i.e limit then we will get only one of these . to include all these we used dense rank .
 
#Q8 to find out if there are bots find the users who have liked every single photo on site
select * from likes ;
select * from users ;
select * from photos ;

select username,u.id ,count(u.id) as likes_by_users from users u
join likes l
on l.user_id=u.id group by u.id 
having likes_by_users in (select count(*) from photos ) ;

#Q9 to know who the celibrities are find users who have never commented on a photo

select * from comments ;
select * from users ;

select id,username from users where id not in (select user_id from comments group by user_id) ;

#Q10 now its time to find both of them together , find the users who have never commented on any photo or have 
# commented on every photo
select * from comments ;
select * from users ;
select * from photos ;





select id  from users where id in 
(with no_comments as (select * from users where id not in ( select user_id from comments ))
select id from no_comments)
union all

(with count_of_photos as ( select user_id ,count(photo_id) as Photo_count from comments  group by user_id),
every_comment as ( select * from count_of_photos where Photo_count = (select count(id) from photos ))
select user_id from every_comment ) ;






select id from users where id in (select c.photo_id,count(c.user_id) from comments as c 
join photos as p
on c.photo_id=p.id
group by c.photo_id)


with on_every  as(
select id from users where id in (select distinct(user_id) from comments) ),
not_every   as(
 select id from users where id not in (select user_id from comments group by user_id))
 
 select username from users where id = on_every


select distinct(user_id) from comments where user_id in ( select photo_id from comments group by photo_id)

use ig_clone

#Q3 to understand when to run ad campaign ,figure out the day of the week most users registered on 
with most_users as (select dayname(created_at) as day_name ,count(*) max_users from users 
group by dayname(created_at))
select day_name,max_users from most_users where max_users in (select max(max_users) from most_users)

# Q4 to target inactive users in an email ad campaign ,find users who have never posted a photo
select * from users
select * from photos

select id,username from users where id not in (select user_id from photos group by user_id)

#Q5 suppose you are running a contest to find out who got most likes on photo . Find out who won 
select * from likes
select * from users
select * from photos

with user_details as (select photo_id,count(user_id) as  likes_count from likes 
group by photo_id)
select u.id,u.username from users as u
inner join photos as p 
on u.id=p.user_id 
where p.id in (select photo_id from user_details where likes_count = (select max(likes_count) from user_details))


#Q6 the investor want to know how many times does the average user posts 

select * from photos
with user_data as (select user_id,count(*) as no_of_post from photos 
group by user_id)
select avg(no_of_post) as average_post from user_data


#Q7 a brand wants to know which hashtag to use on a post and find top 5 most used hashtags
select * from tags
select * from photo_tags

with info as (select tag_id,count(*) as tag_count , dense_rank()  over (order by count(*) desc) as a
from photo_tags
group by tag_id )
select i.tag_count,t.tag_name from info as i
inner join tags as t 
on i.tag_id=t.id 
where tag_id in (select tag_id from info where tag_count in (select (tag_count) from info where a<=5)) order by tag_count desc

#Q8 to find out if there are bots find the users who have liked every single photo on site
select * from users 
select * from likes
select * from photos

with info as  (select user_id ,count(photo_id) as likes_no from likes group by user_id
 having likes_no =(select count(id) from photos))
select id,username from users where id in ( select user_id from info )

#Q9 to know who the celibrities are find users who have never commented on a photo
select * from users 
select * from comments


select id,username  from users where id not in ( select user_id from comments group by user_id)

#Q10 now its time to find both of them together , find the users who have never commented on any photo or have 
# commented on every photo

(select id,username  from users where id not in ( select user_id from comments group by user_id))
union all
(with info as (select user_id,count(*) count_comments  from comments group by user_id)
select id,username from users where id in (select user_id from info where count_comments = (select count(id) from photos))) ;

#OR

(select id,username  from users where id not in ( select user_id from comments group by user_id))
union all
(with info as (select user_id ,count(*) ccounts from comments group by user_id 
having ccounts in (select count(id) from photos))
select id , username from users 
where id in (select user_id from info)) ;