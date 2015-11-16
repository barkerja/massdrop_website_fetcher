require 'rethinkdb'
include RethinkDB::Shortcuts

reconnect_retried = false
conn = begin
  r.connect(
    host: ENV.fetch('RETHINKDB_URL', 'localhost'),
    port: ENV.fetch('RETHINKDB_PORT', 28015),
    db: ENV.fetch('RETHINKDB_DB', 'massdrop_test')
  )
rescue Errno::ECONNREFUSED
  # Server likely hasn't come online yet, give it a few seconds, then retry
  sleep 2

  if !reconnect_retried
    reconnect_retried = true
    retry
  end
end

# If the database does not exist, create it.
if !r.db_list.run(conn).to_a.include?('massdrop_test')
  puts "Creating database..."
  r.db_create('massdrop_test').run(conn)
end

# If the table does not exist, create it.
if !r.db('massdrop_test').table_list.run(conn).to_a.include?('websites')
  puts "Creating table..."
  r.db('massdrop_test').table_create('websites').run(conn)
end
