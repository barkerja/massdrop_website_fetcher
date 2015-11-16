require 'sinatra'
require 'sinatra/base'
require 'json'
require '/app/services/massdrop/fetcher'
require '/app/services/massdrop/website'

class MassdropWebsiteQueue < Sinatra::Base
  configure do
    set :dump_errors, false
    set :raise_errors, true
    set :show_exceptions, false
  end

  get '/' do
    erb :index
  end

  post '/' do
    content_type :json

    if !params.include?('url')
      { error: "URL is a required parameter" }.to_json
    else
      Services::Massdrop::Website.create(params[:url]).to_json
    end
  end

  get '/:id' do
    content_type :json

    @website = Services::Massdrop::Website.find(params[:id])

    if @website
      @website.to_json
    else
      [
        404,
        {
          result: 'not_found',
          message: "Job not found with id #{params[:id]}".to_json
        }
      ]
    end
  end

  error do
    content_type :json
    status 500

    { result: 'error', message: 'System Error' }.to_json
  end
end
