require '/app/services/massdrop/fetcher'
require '/app/services/massdrop/website'
require 'nsq'
require 'json'

module Workers
  class FetchWebsite
    def self.push_job(id)
      producer.write({ id: id }.to_json)
    end

    def self.run
      # Loop to pop off jobs from the message broker
      while message = consumer.pop do
        id = JSON.parse(message.body)['id']

        website = Services::Massdrop::Website.find(id)

        next unless website

        response =
          Services::Massdrop::Fetcher.fetch(website['url'.freeze])

        attributes =
          if response[:error].nil?
            {
              status: Services::Massdrop::Website::SUCCESS,
              response: response[:response]
            }
          else
            {
              status: Services::Massdrop::Website::FAIL,
              error: response[:error]
            }
          end

        begin
          Services::Massdrop::Website.update(id, attributes)
          message.finish
        rescue => e
          # Some sort of system error, requeue for retry later
          message.requeue
          Services::Massdrop::Website.update(id, error: e.message)
        end
      end
    end

    private

    def self.consumer
      @consumer ||=
        Nsq::Consumer.new(
          nsqd: 'localhost:4150',
          topic: 'website',
          channel: 'fetch',
          max_in_flight: 25
        )
    end

    def self.producer
      @producer ||=
        Nsq::Producer.new(
          nsqd: 'localhost:4150',
          topic: 'website'
        )
    end
  end
end
