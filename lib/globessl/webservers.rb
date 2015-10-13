module GlobeSSL
  class Webservers < Base
    attribute :errors, Array[String]
    attribute :list,   Array[Product]
    
    def fetch
      @errors.clear
      @list.clear
      
      response = Client.get('/tools/webservers')
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
        hash.each_pair { |key, value| @list << Webserver.new(:id => key, :name => value) }
        return true
      when '400', '401', '403'
        set_errors(response)
        return false
      else
        return false
      end
    end
    
    def set_errors(response)
      json = response.body
      hash = JSON.parse(json)
      @errors << hash["message"]
    end
  end
end
