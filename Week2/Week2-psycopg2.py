import psycopg2
from user_input import * 

conn = psycopg2.connect(host=host, port=port, database=database, user=user)
cur = conn.cursor()

query = f'''SELECT * FROM epa_site_location WHERE site_id = {site_id}'''
cur.execute(query)
cur.fetchall()
cur.fetchall()

## If your queries include updates such as insert, delete, or update, you need to commit (no autocommit) or  to cancel,  rollback
### Increment site_id by 1 for "site_name".
query = f'''SELECT site_id FROM epa_site_location WHERE  site_name = \'{site_name}\''''
cur.execute(query)
data = cur.fetchall()
sid_list = []
for sid in data:
    sid_list.append(sid[0])
for sid in sid_list:
    query = f'''UPDATE epa_site_location SET site_id = {site_id + 1} WHERE site_id = {sid}'''
    cur.execute(query)

query = f'''SELECT site_id FROM epa_site_location WHERE  site_name = \'{site_name}\''''
cur.execute(query)
data = cur.fetchall()
conn.commit()

query = f'''SELECT site_id FROM epa_site_location WHERE  site_name = \'{site_name}\''''
cur.execute(query)
data = cur.fetchall()
print(data)

## Close communication with the database
cur.close()
conn.close()


