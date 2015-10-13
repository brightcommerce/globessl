module GlobeSSL
  class AccountBalance < Base
    attribute :errors,   Array[String]
    attribute :balance,  Float
    attribute :currency, String

    def fetch
      @errors.clear
      
      response = Client.get('/account/balance')
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
    
        @balance  = hash["balance"]
        @currency = hash["currency"]
        
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