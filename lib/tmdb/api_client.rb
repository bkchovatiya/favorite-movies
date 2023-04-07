require "json"
require "net/http"
require "uri"
require 'open-uri'
require 'net/https'
module TMDB
  BASE_URL = "https://api.themoviedb.org/3"

  cattr_accessor :api_key

  def self.client
    @client ||= ApiClient.new(api_key: self.api_key)
  end

  def self.config
    @config ||= client.get_configuration["body"]
  end

  # This is a minimal TMDB API client, you can extend it as needed.
  # https://www.themoviedb.org/documentation/api
  # https://developers.themoviedb.org/3/getting-started/introduction
  class ApiClient
    def initialize(api_key: nil)
      @api_key = api_key
      @session_id = ENV.fetch("SESSION_ID")
      @account_id = ENV.fetch("ACCOUNT_ID")
    end

    def get_configuration
      get('/configuration')
    end

    def get_movies(page)
      get('/discover/movie', { page: page })
    end

    def get_movie(id)
      get("/movie/#{id}")
    end

    def search(query)
      get('/search/movie', { query: query })
    end

    def favorite(options)
      post("/account/#{@account_id}/favorite", options)
    end

    def favorite_list
      get("/account/#{@account_id}/favorite/movies")
    end

    def get(path, query = nil)
      url = build_url(path, query)
      request = Net::HTTP::Get.new(url.to_s)

      api_request(request)
    end

    def post(url, body = nil)
      url = build_url(url)
      request = Net::HTTP::Post.new(url.to_s, {'Content-Type' => 'application/json'})
      request.body = body.to_json if body

      api_request(request)
    end

    private

    def build_url(path, query = nil)
      url = URI.parse(TMDB::BASE_URL)

      query = { api_key: @api_key, session_id: @session_id }.merge(query.to_h)
      url.query = URI.encode_www_form(query)
      url.path = File.join(url.path, path)

      url
    end

    def api_request(request)
      uri = URI.parse(request.path)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request)}
      parse_response(response)
    end

    def parse_response(response)
      {
        'body' => JSON.parse(response.body),
        'headers' => response.to_hash,
        'status' => response.code,
      }.with_indifferent_access
    end
  end
end
