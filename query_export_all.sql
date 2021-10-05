select l.id, 
       l.name as bnb_name,
       l.neighbourhood_cleansed as neighbourhood,
       l.host_id,
       l.latitude, l.longitude,
       l.room_type, l.accommodates,
       l.bathrooms, l.bedrooms,
       l.beds, l.amenities, l.has_availability,
       l.instant_bookable, l.number_of_reviews,
       h.host_name, h.host_since,
       round(replace(replace(price, '$', ''), ',', '')::numeric, 2) as price,
       replace(h.host_acceptance_rate, '%', '')::numeric as host_acceptance_rate,
       replace(h.host_response_rate, '%', '')::numeric as host_response_rate,
       h.host_response_time, h.host_is_superhost, h.host_listings_count,
       h.host_identity_verified, rs.review_scores_rating, rs.review_scores_cleanliness,
       rs.review_scores_checkin, rs.review_scores_communication,
       rs.review_scores_location, rs.review_scores_value,
       rs.review_scores_accuracy, rs.reviews_per_month
from hosts h 
join listings l 
    on h.host_id = l.host_id
join review_scores rs
    on l.id = rs.listing_id 
where (l.name, l.price, rs.review_scores_rating) is not null