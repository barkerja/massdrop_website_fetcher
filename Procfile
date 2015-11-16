rethinkdb: rethinkdb --bind all --directory /app/data/rethinkdb
web: bundle exec rackup config.ru -p 5000 -s thin -o 0.0.0.0
worker: bin/worker
nsq: nsqd -http-address="0.0.0.0:4151" -tcp-address="0.0.0.0:4150" -data-path="/app/data/nsq"
