import os
import numpy as np
import pandas as pd
import psycopg2

# Setup WDIR
wdir = os.path.abspath('')
reviews = pd.read_csv(os.path.join(wdir, 'data', 'reviews.csv'))

t1_cols_hosts = ['host_id', 'host_name', 'host_since', 'host_location', 'host_response_time',
                 'host_response_rate', 'host_acceptance_rate',
                 'host_is_superhost', 'host_neighbourhood', 'host_listings_count',
                 'host_verifications', 'host_has_profile_pic', 'host_identity_verified']

t2_cols_listings = ['id', 'host_id', 'name', 'description', 'neighbourhood', 'neighbourhood_cleansed',
                    'latitude', 'longitude', 'room_type', 'accommodates', 'bathrooms', 'bedrooms',
                    'beds', 'amenities', 'price', 'minimum_nights', 'maximum_nights',
                    'calendar_updated', 'has_availability', 'instant_bookable', 'number_of_reviews']

t3_cols_review_scores = ['listing_id', 'review_scores_rating', 'review_scores_cleanliness',
                         'review_scores_checkin', 'review_scores_communication',
                         'review_scores_location', 'review_scores_value',
                         'review_scores_accuracy', 'reviews_per_month']

t4_cols_reviews = ['id', 'listing_id', 'date',
                   'reviewer_id', 'reviewer_name', 'comments']

# Connection properties
host = "localhost"
dbname = "airbnb"
user = "postgres"
password = ""

conn_string = "host={0} user={1} dbname={2} password={3}".format(
    host, user, dbname, password)
conn = psycopg2.connect(conn_string, port=5432)
print("Connection established")

cursor = conn.cursor()
body = f'''insert into reviews({','.join([x for x in t4_cols_reviews])})
            values ({','.join(['%s' for i in t4_cols_reviews])})
            on conflict do nothing;'''

df_to_push = reviews[t4_cols_reviews]


def convert_dtypes(x):
    if type(x) == np.int64:
        return int(x)
    elif type(x) == np.float64:
        return float(x)
    elif type(x) == str:
        return x
    elif np.isnan(x):
        return psycopg2.extensions.AsIs('NULL')
    return x


# Push row by row, ensure dtypes are safe to be pushed
for i in range(df_to_push.shape[0]):
    vals = df_to_push.iloc[i, :].to_list()
    vals = tuple(map(convert_dtypes, vals))
    cursor.execute(body, vals)
    if i % 1000 == 0:
        print(f"Completed {i}")


# Clean up
conn.commit()
cursor.close()
conn.close()
