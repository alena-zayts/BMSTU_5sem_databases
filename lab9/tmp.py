import psycopg2
import redis
import json
from time import sleep
from faker import Faker
from random import randint


N_REPEATS = 100
faker = Faker()


def load_workers_to_cache(cur, redis_client):
    cur.execute("select * "
                "from workers")
    with redis_client.pipeline() as pipe:
        for worker in cur.fetchall():
            worker_info = {'department_id': worker[1], 'first_name': worker[2],
                           'second_name': worker[3], 'experience': worker[4]}
            pipe.hset(f'{worker[0]}', worker_info)
            # redis_client.set(f'{worker[0]}', json.dumps(worker[1:]))
            #res = redis_client.hget(f'{worker[0]}', 'first_name')
            res = redis_client.get(f'{worker[0]}: first_name')
            print(f'{worker[0]}', json.loads(res))


def add_worker(cur, redis_client, i):
    firstName, SecondName = faker.name().split()[:2]
    department_id = randint(0, 100)
    experience = randint(0, 80)
    cur.execute("insert into workers (worker_id, first_name, second_name, department_id, experience) "
                f"values ({i}, '{firstName}', '{SecondName}', {department_id}, {experience})")

    redis_client.set(f'{i}', json.dumps([firstName, ]))
    print(f"worker added: ({i}, '{firstName}', '{SecondName}', {department_id}, {experience})")


def main():
    with psycopg2.connect(
            database="postgres",
            user="postgres",
            password="4541",
            host="127.0.0.1",
            port="5432"
    ) as con, \
            con.cursor() as cur, \
            redis.Redis() as redis_client:
        load_workers_to_cache(cur, redis_client)
        add_worker(cur, redis_client, 10000000)

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

        redis_client.delete("stats")
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
    main()


    # answ = count_workers_as_departments()
    # print('Количество сотрудников в каждом отделе')
    # for x in answ:
    #     print(x)
