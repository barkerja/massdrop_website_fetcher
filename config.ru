#:.unshift(File.dirname(__FILE__))

# Run DB initializer
require '/app/config/initializers/rethinkdb_initializer'
require '/app/app'
run MassdropWebsiteQueue
