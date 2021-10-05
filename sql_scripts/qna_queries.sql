-- Q2
select  h.host_id, 
        round(avg(rs.review_scores_rating)::numeric, 2) as host_avg_rating,
        count(l.id) as no_of_listings,
        max(case 
            when h.host_is_superhost='t' then 1
            else 0
            end) as superhost
from hosts h join listings l 
    on h.host_id = l.host_id
join review_scores rs
    on l.id = rs.listing_id 
group by h.host_id
having avg(rs.review_scores_rating) is not null
    and count(l.id) > 1
    and sum(l.number_of_reviews) > 500
order by host_avg_rating DESC;


-- Q-3
with summary as
    (select *, 
    replace(replace(price, '$', ''), ',', '')::numeric as price_new,
    row_number() over(partition by l.neighbourhood_cleansed order by rs.review_scores_rating desc) as rn
    from listings l join review_scores rs
    on l.id = rs.listing_id
    where rs.review_scores_rating is not null
    and replace(replace(price, '$', ''), ',', '')::numeric < 100 )
select listing_id, neighbourhood_cleansed, review_scores_rating, price_new
from summary
where rn in (1,2,3)
order by neighbourhood_cleansed;


-- Q-4
select (current_date - host_since::date)/365 as host_for,
        round(avg(rs.review_scores_rating)::numeric, 2)
from hosts h join listings l 
    on h.host_id = l.host_id
join review_scores rs
    on l.id = rs.listing_id 
where h.host_is_superhost is not null 
and h.host_is_superhost = 'f'
group by host_for
having (current_date - host_since::date)/365 is not null
and sum(l.number_of_reviews) > 50
order by host_for


-- Q-5
select neighbourhood_cleansed,
       round(avg(replace(replace(price, '$', ''), ',', '')::numeric), 2) as price_shared_room
from listings
where room_type = 'Shared room'
group by neighbourhood_cleansed
order by price_shared_room limit 10;

select neighbourhood_cleansed,
       round(avg(replace(replace(price, '$', ''), ',', '')::numeric), 2) as price_private_room
from listings
where room_type = 'Private room'
group by neighbourhood_cleansed
order by price_private_room limit 10;

select neighbourhood_cleansed,
       round(avg(replace(replace(price, '$', ''), ',', '')::numeric), 2) as price_entire_home
from listings
where room_type = 'Entire home/apt'
group by neighbourhood_cleansed
order by price_entire_home limit 10;