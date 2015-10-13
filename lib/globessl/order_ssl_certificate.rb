require_relative 'country_codes'

module GlobeSSL
  class OrderSSLCertificate < Base
    EXPIRY_PERIODS = [0, 1, 2, 3].freeze
    
    attribute :admin_firstname,       String
    attribute :admin_lastname,        String
    attribute :admin_email,           String
    attribute :admin_org,             String        # [optional] Required for OV and EV SSL
    attribute :admin_jobtitle,        String         
    attribute :admin_address,         String        # [optional] Required for OV and EV SSL
    attribute :admin_city,            String        # [optional] Required for OV and EV SSL
    attribute :admin_country,         String        # [optional] Required for OV and EV SSL, must be one in COUNTRY_CODES
    attribute :admin_phone,           String
    attribute :amount,                Float
    attribute :approver_email,        String        # [optional] Required when dcv_method = email
    attribute :approver_emails,       String        # [optional] Required for SAN/UCC/Multi-Domain SSL, required only if dcv_method = email
    attribute :certificate_id,        Integer
    attribute :currency,              String
    attribute :dcv_method,            String        # one of DomainControlValidation::METHODS
    attribute :dcv_file_path,         String        # The path to write the domain validation text file is it is used
    attribute :dns_names,             String        # [optional] Required for SAN/UCC/Multi-Domain SSL
    attribute :errors,                Array[String]          
    attribute :csr,                   CertificateSigningRequest
    attribute :optional_admin_params, Boolean, :default => false
    attribute :optional_org_params,   Boolean, :default => false
    attribute :order_id,              Integer               
    attribute :org_name,              String        # [optional] Required for OV and EV SSL
    attribute :org_division,          String        # [optional] Required for OV and EV SSL
    attribute :org_address,           String        # [optional] Required for OV and EV SSL
    attribute :org_city,              String        # [optional] Required for OV and EV SSL
    attribute :org_state,             String        # [optional] Required for OV and EV SSL
    attribute :org_country,           String        # [optional] Required for OV and EV SSL, must be one in COUNTRY_CODES
    attribute :org_postalcode,        String        # [optional] Required for OV and EV SSL
    attribute :org_phone,             String        # [optional] Required for OV and EV SSL
    attribute :period,                Integer       # must be one of 1, 2 or 3 years (see EXPIRY_PERIODS); pass 0 for free product 
    attribute :product,               Product       # should be retrieved using Product#fetch
    attribute :webserver_type,        Integer       # can be retrieved using WebServers#fetch
    
    def dcv_method=(value)
      @dcv_method = value.downcase
    end
    
    def purchase!
      @errors.clear
      return false unless valid?
      
      # If the dcv_method is 'http' or 'https', prepare the validation text file.
      # Use MD5 for .txt file name.
      # Write SHA1 to first line and comodoca.com to 2nd line.
      # Save to web app root (@txt_file_path).
      unless @dcv_method == "email"
        DomainControlValidation.write_file(@csr.fingerprint_sha1, @csr.fingerprint_md5, @dcv_file_path)
      end
      
      params = { 
        "admin_firstname" => @admin_firstname,
        "admin_lastname"  => @admin_lastname,
        "admin_email"     => @admin_email,
        "admin_phone"     => @admin_phone,
        "csr"             => @csr.csr_code,
        "dcv_method"      => @dcv_method,
        "period"          => @period,
        "product_id"      => @product.id,
        "webserver_type"  => @webserver_type
      }
      
      admin_params = {
        "admin_org"       => @admin_org,
        "admin_jobtitle"  => @admin_jobtitle,
        "admin_address"   => @admin_address,
        "admin_city"      => @admin_city,
        "admin_country"   => @admin_country
      }
      
      email_params = {
        "approver_email"  => @approver_email
      }

      multiple_emails_params = {
        "approver_emails" => @approver_emails
      }
      
      org_params = {
        "org_name"        => @org_name,
        "org_division"    => @org_division,
        "org_address"     => @org_address,
        "org_city"        => @org_city,
        "org_state"       => @org_state,
        "org_country"     => @org_country,
        "org_postalcode"  => @org_postalcode,
        "org_phone"       => @org_phone
      }

      multi_domain_params = {
        "dns_names" => @dns_names
      }

      if @product.validation == "dv"
        if @dcv_method == "email"
          params.merge!(email_params)
        end
      
        if @product.multi_domain
          params.merge!(multi_domain_params)
        end
        
        if @dcv_method == "email" && @product.multi_domain
          params.merge!(multiple_emails_params)
        end
        
        if @optional_admin_params
          params.merge!(admin_params)
        end
        
        if @optional_org_params
          params.merge!(org_params)
        end
      else
        params.merge!(admin_params)
        params.merge!(org_params)
      end
      
      response = Client.post('/order/ssl', params)
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
    
        @order_id       = hash["order_id"]
        @certificate_id = hash["certificate_id"]
        @amount         = hash["amount"]
        @currency       = hash["currency"]
        
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
      unless @dcv_method
        @errors << "dcv_method is required"
      else
        unless DomainControlValidation::METHODS.include?(@dcv_method)
          @errors << "dcv_method must be one of 'email', 'http' or 'https'"
        end

        unless @dcv_method == "email"
          unless @dcv_file_path
            @errors << "dcv_file_path is required"
          end
        end
      end
      
      if @product.multi_domain
        unless @dns_names.size > (@product.min_domains - 1)
          @errors << "dns_names are required"
        end
      end
      
      if @dcv_method == "email"
        unless @approver_email
          @errors << "approver_email is required"
        end
        
        if @product.multi_domain
          unless @approver_emails.size == @dns_names.size
            @errors << "approver_emails are required"
          end
        end
      end
      
      unless @product.validation == "dv"  # if not domain validation
        unless @admin_org
          @errors << "admin_org is required"
        end
        
        unless @admin_address
          @errors << "admin_address is required"
        end
        
        unless @admin_city
          @errors << "admin_city is required"
        end

        unless @admin_country
          @errors << "admin_country is required"
        else
          unless COUNTRY_CODES.has_key?(@admin_country)
            @errors << "admin_country must be one in COUNTRY_CODES"
          end
        end

        unless @org_name
          @errors << "org_name is required"
        end
        
        unless @org_division
          @errors << "org_division is required"
        end

        unless @org_address
          @errors << "org_address is required"
        end

        unless @org_city
          @errors << "org_city is required"
        end

        unless @org_state
          @errors << "org_state is required"
        end
        
        unless @org_country
          @errors << "org_country is required"
        else
          unless COUNTRY_CODES.has_key?(@org_country)
            @errors << "org_country must be one in COUNTRY_CODES"
          end
        end
        
        unless @org_postalcode
          @errors << "org_postalcode is required"
        end
        
        unless @org_phone
          @errors << "org_phone is required"
        end
      end
      
      unless @admin_firstname
        @errors << "admin_firstname is required"
      end

      unless @admin_lastname
        @errors << "admin_lastname is required"
      end

      unless @admin_email
        @errors << "admin_email is required"
      end
      
      unless @admin_jobtitle
        @errors << "admin_jobtitle is required"
      end

      unless @admin_phone
        @errors << "admin_phone is required"
      end

      unless @admin_phone
        @errors << "admin_phone is required"
      end
      
      unless @csr
        @errors << "certificate signing request (csr) is required"
      end
      
      unless @period
        @errors << "period is required"
      else
        unless EXPIRY_PERIODS.include?(@period)
          @errors << "period must be 1, 2 or 3 years or 0 if product is free"
        end
      end
      
      unless @webserver_type
        @errors << "webserver_type is required"
      end
      
      unless @product
        @errors << "product is required"
      end

      if @errors.any?
        return false
      else
        return true
      end
    end
  end
end
