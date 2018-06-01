import redis

redis_source = redis.Redis(
    host='172.31.11.41',
    port=6379)

redis_dest = redis.Redis(
    host='172.31.30.189',
    port=6379)

all_keys = redis_source.keys()
for key in all_keys:
  print(key)
  value = redis_source.get(key)
  redis_dest.set(key, value)
