--Вывести количество фильмов в каждой категории, отсортировать по убыванию
select
	c.name,
	count(fc.film_id) as films_count
from
	category c
join film_category fc 
on
	c.category_id = fc.category_id
group by
	c.name
order by
	films_count desc;

--Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию
select
	a.first_name || ' ' || a.last_name as actor_name,
	count(r.rental_id) as rental_count
from
	actor a
join film_actor fa on
	a.actor_id = fa.actor_id
join inventory i on
	i.film_id = fa.film_id
join rental r on
	r.inventory_id = i.inventory_id
group by
	a.actor_id, actor_name
order by
	rental_count desc
limit 10;

--Вывести категорию фильмов, на которую потратили больше всего денег
select
	c.name,
	sum(p.amount) as total_costs
from
	category c
join film_category fc on
	c.category_id = fc.category_id
join inventory i on
	i.film_id = fc.film_id
join rental r on
	r.inventory_id = i.inventory_id
join payment p on
	p.rental_id = r.rental_id
group by
	c.name
order by
	total_costs desc
limit 1;

--Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN
select
	f.title
from
	film f
where not exists (
	select * from inventory i 
	where f.film_id = i.film_id
) 

	
select
	f.title
from
	film f
left join inventory i on
	f.film_id = i.film_id
where
	i.inventory_id is null;

--Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”
--Если у нескольких актеров одинаковое кол-во фильмов, вывести всех
select
	name,
	films_count
from
	(
	select
		a.first_name || ' ' || a.last_name as name,
		count(fc.film_id) as films_count,
		dense_rank() over (order by count(fc.film_id) desc) as rank
	from
		actor a
	join film_actor fa on
		a.actor_id = fa.actor_id
	join film_category fc on
		fc.film_id = fa.film_id
	join category c on
		c.category_id = fc.category_id
	where
		c.name = 'Children'
	group by
		a.actor_id, name
) as ranked_actors
where
	rank <= 3
order by
	films_count desc;
--Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1)
--Отсортировать по количеству неактивных клиентов по убыванию
select
	c.city,
	sum(case when c2.active = 1 then 1 else 0 end) as active_clients,
	sum(case when c2.active = 0 then 1 else 0 end) as inactive_clients
from
	city c
join address a on
	a.city_id = c.city_id
join customer c2 on
	c2.address_id = a.address_id
group by
	c.city
order by
	inactive_clients desc;

--Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
--и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
with RentHours as (
    select
        c.city as city_name,
        ca.name as category,
        sum((r.return_date - r.rental_date) * 24) as total_rental_hours
    from
        city c
    join address a on
        c.city_id = a.city_id
    join customer cu on
        a.address_id = cu.address_id
    join rental r on
        cu.customer_id = r.customer_id
    join inventory i on
        r.inventory_id = i.inventory_id
    join film_category fc on
        i.film_id = fc.film_id
    join category ca on
        ca.category_id = fc.category_id
    where
        r.return_date is not null
    group by
        c.city,
        ca.name
),
MaxHoursA as (
    select
        city_name,
        category,
        max(total_rental_hours) as max_hours
    from
        RentHours
    where
        category like 'A%'
    group by
        city_name,
        category
),
MaxHoursCities as (
    select
        city_name,
        category,
        max(total_rental_hours) as max_hours
    from
        RentHours
    where
        city_name like '%-%'
    group by
        city_name,
        category
)
select
    city_name,
    category,
    max_hours
from
    MaxHoursA
union all 
select
    city_name,
    category,
    max_hours
from
    MaxHoursCities
order by
    max_hours desc;
















