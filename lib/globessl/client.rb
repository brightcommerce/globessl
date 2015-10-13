require 'net/http'
require 'net/https'

module GlobeSSL
  class Client
    @headers = {
      'User-Agent' => GlobeSSL::VERSION::SUMMARY,
      'Accept'     => 'application/json',
      'X-API-KEY'  => GlobeSSL.api_key
    }
    
    def self.get(endpoint, params = {})
      begin
        uri = URI.parse([GlobeSSL.api_uri, endpoint].join)
        uri.query = URI.encode_www_form(params) if params.any?
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        request = Net::HTTP::Get.new(uri, @headers)
        response = http.request(request)
      rescue StandardError => error
        puts "HTTP Request failed (#{error.message})"
      end
    end
    
    def self.post(endpoint, params = {})
      begin
        uri = URI.parse([GlobeSSL.api_uri, endpoint].join)
        body = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        request = Net::HTTP::Post.new(uri, @headers)
        request.add_field "Content-Type", "application/x-www-form-urlencoded"
        request.body = body
        response = http.request(request)
      rescue StandardError => error
        puts "HTTP Request failed (#{error.message})"
      end
    end
  end
end
