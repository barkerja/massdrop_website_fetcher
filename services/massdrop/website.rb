require 'rethinkdb'
require '/app/workers/fetch_website'

module Services
  module Massdrop
    class Website
      extend RethinkDB::Shortcuts

      SUCCESS    = 'success'.freeze
      FAIL       = 'failed'.freeze
      PROCESSING = 'processing'.freeze

      def self.find(id)
        r.table('websites').get(id).run(conn)
      end

      def self.create(url)
        response = r.table('websites').insert({
          created_at: Time.now,
          updated_at: Time.now,
          status: PROCESSING,
          url: url
        }).run(conn, return_changes: true)['changes'][0]['new_val']

        Workers::FetchWebsite.push_job(response['id'])

        response
      end

      def self.update(id, attributes = {})
        r.table('websites').get(id).update(
          attributes.merge(updated_at: Time.now)
        ).run(conn, return_changes: true)['changes'][0]['new_val']
      end

      def self.delete(id)
        r.table('websites').get(id).delete.run(conn)
      end

      def self.get_all
        r.table('websites').run(conn).to_a
      end

      private

      def self.conn
        @conn ||=
          r.connect(
            host: ENV.fetch('RETHINKDB_URL', 'localhost'),
            port: ENV.fetch('RETHINKDB_PORT', 28015),
            db: ENV.fetch('RETHINKDB_DB', 'massdrop_test')
          )
      end

    end
  end
end
