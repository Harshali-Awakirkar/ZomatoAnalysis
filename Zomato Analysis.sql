create database personal_project;
use personal_project;


drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-09-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-02-09'),
(2,'2015-01-15'),
(3,'2014-4-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-9-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select count(userid) from sales;
-- 1.What is the total amount each customer spent on zomato account?
select s.userid, sum(p.price) as Total_Amt_Spent
from sales s
inner join product p
on s.product_id = p.product_id
group by s.userid
order by userid;
;

-- 2. How many days each customer visited Zomato?
select userid, count(distinct(created_date)) as Distinct_days
from sales
group by userid;

-- 3.What was the first product purchased by the each customer

select * 
from (select *, rank() over(partition by userid order by created_date) as rnk from sales) as Source
where rnk = 1;


-- 4. what is the most purchased item on the menu and how many times was it purchased by all customers

select userid, count(product_id)
from sales
where product_id = (select  product_id
from sales
group by product_id
limit 1)
group by userid;

-- 5. which item was the most popular for each customer?
select * from (select *, rank() over(partition by userid order by cnt desc) as rnk
from
	(select userid, product_id, count(product_id) as cnt
	from sales
	group by userid, product_id) as a) b
where rnk = 1;

-- 6. which item purchased first by the customer after they become a member
Select * from (select source1.*, rank() over(partition by userid order by created_date) as rnk from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and  created_date >= gold_signup_date) Source1) source2
where rnk = 1 ;

-- 7. Which item was purchased just before the customer became a member?
select * from
	(select source1.*, rank() over (partition by userid order by created_date desc) rnk 
	from
		(select s.userid, s.created_date, s.product_id, g.gold_signup_date
		from sales s
		inner join goldusers_signup g 
		on s.userid = g.userid
		and created_date < gold_signup_date) as source1) source2
where rnk = 1;


-- 8. what is the total orders and amount spent for each member before they become a member?
select userid, count(created_date) as Order_Purchased, sum(price) as Price 
from(select source1.*, p.price
	from (select s.userid, s.created_date, s.product_id, g.gold_signup_date
		from sales s
		inner join goldusers_signup g 
		on s.userid = g.userid
		and created_date < gold_signup_date) source1
inner join product p 
on p.product_id = source1.product_id) source2
group by userid
order by userid;

/* 9. if buying each product generates points for example 5rs. = 2 zomato point and each product has different purchasing points
 for eg. for p1-5rs-1 zomato point, for p2 -10 rs - 5 zomato point, for p3 - 5 rs - 1 zomato point
 Calculate points collected by each customers and for which product most points have been given till now. */
select userid, sum(total_points) * 2.5 as total_money_earned from
(select e.*, amt/point as total_points 
from (
	select d.*, case when product_id = 1 then 5
	when product_id = 2 then 2 when product_id = 3 then 5 end as point
	from (select c.userid, c.product_id, sum(price) as amt
		from(select s.*, p.price
				from sales s
				inner join product p 
				on s.product_id = p.product_id) C
		group by c.userid, c.product_id) d) e) f 
group by userid;


--creating gold users table
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

--creating users table
CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

--creating sales table
CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

--creating product table
CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);
 
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1.what is total amount each customer spent on zomato ?
SELECT a.userid,sum(b.price)total_amount_spend from sales as a INNER JOIN product as b
on a.product_id = b.product_id
GROUP BY a.userid
order by a.userid

--2.How many days has each customer visited zomato?

SELECT userid,count(DISTINCT created_date) from sales GROUP by userid;

--3.what was the first product purchased by each customer?

SELECT * from
(SELECT *,rank() over (PARTITION by userid ORDER by created_date)rnk from sales) a WHERE rnk=1;

--4.what is most purchased item on menu & how many times was it purchased by all customers ?

SELECT userid,COUNT(product_id)purchased_count from sales where product_id=
(SELECT product_id from sales group by product_id order by COUNT(product_id) desc LIMIT 1 )GROUP by userid

--5.which item was most popular for each customer?

SELECT * from
(SELECT *,rank() over(PARTITION by userid order by cnt desc)rnk from
(SELECT userid,product_id,count(product_id) cnt from sales group by userid,product_id )a)b
WHERE rnk=1;

--6.which item was purchased first by customer after they become a member ?

SELECT * from(
SELECT c.*,rank() over(PARTITION by userid ORDER by created_date)rnk from
(SELECT a.userid,b.created_date,b.product_id,a.gold_signup_date from goldusers_signup as a 
INNER JOIN sales as b on a.userid = b.userid AND created_date >= gold_signup_date)c) d WHERE rnk = 1;

--7. which item was purchased just before the customer became a member?

SELECT * from(
SELECT c.*,rank() over(PARTITION by userid ORDER by created_date DESC)rnk from
(SELECT a.userid,b.created_date,b.product_id,a.gold_signup_date from goldusers_signup as a 
INNER JOIN sales as b on a.userid = b.userid AND created_date <= gold_signup_date)c) d WHERE rnk = 1;

-- 8. what is total orders and amount spent for each member before they become a member?

SELECT userid,COUNT(created_date)total_orders,sum(price)Total_amount from 
(SELECT c.*,d.price from 
(SELECT a.userid,b.created_date,b.product_id,a.gold_signup_date from goldusers_signup as a 
INNER JOIN sales as b on a.userid = b.userid AND created_date <= gold_signup_date)c 
INNER JOIN product as d on d.product_id = c.product_id)e 
GROUP by userid
ORDER by userid;


/*9. If buying each product generates points for eg 5rs=2 zomato point and each product 
has different purchasing points for eg for p1 5rs=1 zomato point,for p2 10rs=zomato point
and p3 5rs=1 zomato point 2rs =1zomato point, calculate points collected by each customer
and for which product most points have been given till now.*/


SELECT userid,sum(total_Points)*2.5 total_amount_earned from
(select e.*,amt/points total_points from
(SELECT d.*,case when product_id=1 then 5 
WHEN product_id=2 then 2
WHEN product_id=3 then 5 ELSE 0 end as points from(
SELECT c.userid,c.product_id,sum(price)amt FROM(
SELECT a.*,b.price from sales as A 
INNER JOIN product as b on a.product_id=b.product_id)c GROUP by userid,product_id)d)e)f GROUP by userid;


/* 10. In the first 1 year after a customer joins the gold program (including their join date) irrespective
 of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3
 and what was their points earning in the first year? */ 
-- 1 zp = 2 rs so 0.5 zp = 1 rs
select c.*, d.price * 0.5 as total_point_earned from
	(select s.userid, s.created_date, s.product_id, g.gold_signup_date
	from sales s inner join goldusers_signup g
	on s.userid = g.userid and created_date >= gold_signup_date and created_date < date_add(g.gold_signup_date, interval 1 year)) c 
inner join product d on c.product_id = d.product_id;


-- 11. Rank all the transaction of the customers
select *, rank() over (partition by userid order by created_date) as rnk 
from sales;
 

/* 12. rank all the transactions for each member wherever they are a zomato gold member for every non gold member transaction 
mark as na. */
select c.*, 
case when gold_signup_date is null then 'na' 
else rank() over(partition by userid order by created_date desc ) end as rnk from
	(SELECT a.userid,a.created_date,a.product_id,b.gold_signup_date from sales as a 
	LEFT JOIN  goldusers_signup as b on a.userid = b.userid AND created_date >= gold_signup_date)c
