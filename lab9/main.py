import psycopg2
import redis
import json
from time import sleep

N_REPEATS = 100

def count_workers_as_departments():
    with psycopg2.connect(
            database="postgres",
            user="postgres",
            password="4541",
            host="127.0.0.1",
            port="5432"
    ) as con, \
            con.cursor() as cur, \
            redis.Redis() as redis_client:

        #redis_client.delete("stats")
        cache_value = redis_client.get("stats")

        if cache_value is not None:
            print('found in cache')
            return json.loads(cache_value)

        print('ask db')
        cur.execute("select department_id, count(*) as amount "
                    "from workers "
                    "group by department_id "
                    "order by department_id;")
        result = cur.fetchall()
        redis_client.set("stats", json.dumps(result))
        return result


def ask_bd(cur, sleep_time=5):
    while True:
        cur.execute("select department_id, count(*) as amount "
                    "from workers "
                    "group by department_id "
                    "order by department_id;")
        result = cur.fetchall()
        sleep(sleep_time)


def ask_redis(cur, sleep_time=5):
    while True:
        cur.execute("select department_id, count(*) as amount "
                    "from workers "
                    "group by department_id "
                    "order by department_id;")
        result = cur.fetchall()
        sleep(sleep_time)


if __name__ == "__main__":
    answ = count_workers_as_departments()
    print('Количество сотрудников в каждом отделе')
    for x in answ:
        print(x)
