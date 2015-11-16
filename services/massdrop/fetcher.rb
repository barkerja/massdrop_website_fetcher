module Services
  module Massdrop
    class Fetcher
      REDIRECT_CODES = (300..308).to_a.freeze
      SUCCESS_CODES = [200].freeze
      FAIL_CODES = [*(400..499).to_a, *(500..599).to_a].freeze

      REQUEST_TIMEOUT = 5 # Timeout in seconds
      ENCODING = 'UTF-8'.freeze

      ERRORS = {
        invalid_url: 'Invalid URL'.freeze,
        timeout: 'request_timeout'.freeze,
        error: 'system_error'.freeze
      }.freeze

      # Fetch a given URL
      def self.fetch(url)
        url = "http://#{url}" unless url =~ /https?\:\/\//i
        uri = URI.parse(url)

        r =
          Net::HTTP.start(
            uri.host,
            uri.port,
            open_timeout: REQUEST_TIMEOUT,
            read_timeout: REQUEST_TIMEOUT,
            use_ssl: uri.port == 443
          ) do |http|
            http.request(Net::HTTP::Get.new(uri))
          end

        # If a redirect and response header returns a location, retry request
        # at new location.
        if REDIRECT_CODES.include?(r.code.to_i) && !r.header['location'].nil?
          return fetch(r.header['location'])
        end

        format_response(
          response: r.body.force_encoding(ENCODING).encode(ENCODING)
        )
      rescue URI::InvalidURIError
        # URI could not parse the given URL
        format_response(error: ERRORS[:invalid_url])
      rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED
        # In a real world scenario, more info would be logged
        # and possibly the operation retried with a backoff and
        # retry limit.
        format_response(error: ERRORS[:timeout])
      rescue
        # General rescue to catch all other errors
        format_response(error: ERRORS[:error])
      end

      private

      def self.format_response(response: nil, error: nil)
        {
          response: response,
          error: error
        }.freeze
      end
    end
  end
end
