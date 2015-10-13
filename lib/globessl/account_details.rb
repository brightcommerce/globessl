module GlobeSSL
  class AccountDetails < Base
    attribute :errors,        Array[String]
    attribute :status,        String
    attribute :account_id,    Integer
    attribute :balance,       Float
    attribute :total_balance, Float
    attribute :account_type,  Integer
    attribute :email_address, String
    attribute :name,          String
    attribute :company,       String
    attribute :address,       String
    attribute :city,          String
    attribute :state,         String
    attribute :country,       String
    attribute :postal_code,   String
    
    def fetch
      @errors.clear
      
      response = Client.get('/account/details')
      
      case response.code
      when '200'
        json = response.body
        hash = JSON.parse(json)
    
        @status        = hash["status"]
        @account_id    = hash["account_id"]
        @balance       = hash["balance"]
        @total_balance = hash["total_balance"]
        @account_type  = hash["account_type"]
        @email_address = hash["email"]
        @name          = hash["name"]
        @company       = hash["company"]
        @address       = hash["address"]
        @city          = hash["city"]
        @state         = hash["state"]
        @country       = hash["country"]
        @postal_code   = hash["postal_code"]
        
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