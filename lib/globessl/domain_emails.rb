module GlobeSSL
  class DomainEmails < Base
    attribute :domain, String
    attribute :list,   Array[String]
    attribute :errors, Array[String]
    
    def fetch
      @errors.clear
      @list.clear
      
      unless @domain
        @errors << "domain is required"
        return false
      end
      
      response = Client.get('/tools/domainemails', { 'domain' => @domain })
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
        hash.each { |email| @list << email }
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
