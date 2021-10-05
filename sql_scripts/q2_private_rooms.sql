select l.id, 
       l.name as place_name,
       l.neighbourhood_cleansed as neighbourhood,
       round(replace(replace(price, '$', ''), ',', '')::numeric, 2) as price_new,
       replace(h.host_acceptance_rate, '%', '')::numeric as acceptance_rate,
       replace(h.host_response_rate, '%', '')::numeric
from hosts h 
join listings l 
    on h.host_id = l.host_id
join review_scores rs
    on l.id = rs.listing_id 
where replace(replace(price, '$', ''), ',', '')::numeric < 
                    (select avg(replace(replace(price, '$', ''), ',', '')::numeric) as price_mod
                     from listings
                     where room_type = 'Private room')
and l.room_type != 'Shared room'
and replace(h.host_acceptance_rate, '%', '')::numeric > 80
and replace(h.host_response_rate, '%', '')::numeric > 80
and l.number_of_reviews > 20
and l.has_availability = 't'
and h.host_identity_verified = 't'
and h.host_response_time = 'within an hour'
and rs.review_scores_rating > (select avg(r.review_scores_rating)
                     from listings lst 
                     join review_scores r
                     on lst.id = r.listing_id 
                     where lst.room_type = 'Private room')