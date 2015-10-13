module GlobeSSL
  class Product < Base
    attribute :errors,       Array[String]
    attribute :id,           Integer
    attribute :name,         String
    attribute :validation,   String
    attribute :wildcard,     Boolean
    attribute :multi_domain, Boolean
    attribute :min_domains,  Integer
    attribute :max_domains,  Integer
    attribute :brand,        String
    
    def fetch
      @errors.clear
      
      unless @id
        @errors << "product id is required"
        return false
      end
      
      response = Client.get('/products/details', { 'product_id' => @id })
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
        
        @name         = hash["name"]
        @validation   = hash["validation"]
        @wildcard     = hash["wildcard"] == 1 ? true : false
        @multi_domain = hash["mdc"] == 1 ? true : false
        @min_domains  = hash["mdc_min"]
        @max_domains  = hash["mdc_max"]
        @brand        = hash["brand"]
        
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
