module GlobeSSL
  class Products < Base
    attribute :errors, Array[String]
    attribute :list,   Array[Product]
    
    def fetch
      @errors.clear
      @list.clear
      
      response = Client.get('/products/list')
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
        
        collection = hash["products"].inject([]) { |memo, element| memo << element.last }
      
        collection.each do |product|
          @list << Product.new(
            :id         => product["id"],
            :name       => product["name"],
            :validation => product["validation"],
            :wildcard   => product["wildcard"],
            :mdc        => product["mdc"],
            :mdc_min    => product["mdc_min"],
            :mdc_max    => product["mdc_max"],
            :brand      => product["brand"]
          )
        end
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
