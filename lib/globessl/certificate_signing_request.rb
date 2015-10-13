require_relative 'country_codes'

module GlobeSSL
  class CertificateSigningRequest < Base    
    attribute :errors,                   Array[String]
    attribute :country_name,             String        # Must be one in COUNTRY_CODES
    attribute :state_or_province_name,   String
    attribute :locality_name,            String
    attribute :organization_name,        String
    attribute :organizational_unit_name, String
    attribute :common_name,              String
    attribute :email_address,            String
    attribute :csr_code,                 String
    attribute :csr_code_decoded,         String
    attribute :private_key,              String
    attribute :fingerprint_sha1,         String
    attribute :fingerprint_md5,          String
  
    def country_name=(value)
      if value
        @country_name = value.upcase
      else
        @country_name = value # nil
      end
    end
  
    def fetch
      @errors.clear
      
      return false unless valid?
      
      params = { 
        "countryName"            => @country_name,
        "stateOrProvinceName"    => @state_or_province_name,
        "localityName"           => @locality_name,
        "organizationName"       => @organization_name,
        "organizationalUnitName" => @organizational_unit_name,
        "commonName"             => @common_name,
        "emailAddress"           => @email_address
        }
      
      response = Client.post('/tools/autocsr', params)
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
    
        @private_key      = hash["key"] #.delete!("\n") # delete newlines
        @csr_code         = hash["csr"] #.delete!("\n") # delete newlines
        @fingerprint_sha1 = hash["sha1"]
        @fingerprint_md5  = hash["md5"]
        
        return true
      when '400', '401', '403'
        set_errors(response)
        return false
      else
        return false
      end
    end
  
    def decode
      @errors.clear
      response = Client.post('/tools/decodecsr', { "csr" => @csr_code })
      
      case response.code
      when '200'
        @csr_code_decoded = response.body
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
    
    def valid?
      validate
    end
  
    def validate
      unless @country_name
        @errors << "country_name is required"
      end
      
      unless COUNTRY_CODES.has_key?(@country_name)
        @errors << "country_name must be one in COUNTRY_CODES"
      end
      
      unless @state_or_province_name
        @errors << "state_or_province_name is required"
      end
      
      unless @locality_name
        @errors << "locality_name is required"
      end
      
      unless @organization_name
        @errors << "organization_name is required"
      end
      
      unless @organizational_unit_name
        @errors << "organizational_unit_name is required"
      end

      unless @common_name
        @errors << "common_name is required"
      end

      unless @email_address
        @errors << "email_address is required"
      end

      if @errors.any?
        return false
      else
        return true
      end
    end
  end
end
