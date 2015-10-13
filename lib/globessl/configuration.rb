module GlobeSSL
  class Configuration
    attr_writer :api_key, :api_uri
    
    def api_key
      @api_key ||= ENV['GLOBESSL_API_KEY']
    end
    
    def api_uri
      @api_uri ||= "https://api.globessl.com/v2"
    end
  end
end
