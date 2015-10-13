module GlobeSSL
  class SSLCertificate < Base
    attribute :id,                 Integer
    attribute :order_id,           Integer
    attribute :partner_order_id,   Integer
    attribute :status,             String
    attribute :status_description, String
    attribute :dcv_method,         String
    attribute :dcv_email,          String
    attribute :product,            Product
    attribute :domain,             String
    attribute :domains,            String
    attribute :total_domains,      Integer
    attribute :period,             Integer
    attribute :valid_from,         Date
    attribute :valid_till,         Date
    attribute :csr_code,           String
    attribute :crt_code,           String
    attribute :ca_code,            String
    attribute :webserver_type,     Integer

    def fetch
      @errors.clear
      
      unless @id
        @errors << "cerificate id is required"
        return false
      end
      
      response = Client.get('/certificates/get', { "id" => @id })
      
      case response.code
      when '200'  
        json = response.body
        hash = JSON.parse(json)
        
        @order_id           = hash["order_id"]
        @partner_order_id   = hash["partner_order_id"]
        @status             = hash["status"]
        @status_description = hash["status_description"]
        @dcv_method         = hash["dcv_method"]
        @dcv_email          = hash["dcv_email"]
        @domain             = hash["domain"]
        @domains            = hash["domains"]
        @total_domains      = hash["total_domains"]
        @period             = hash["period"]
        @valid_from         = hash["valid_from"]
        @valid_till         = hash["valid_till"]
        @csr_code           = hash["csr_code"]
        @crt_code           = hash["crt_code"]
        @ca_code            = hash["ca_code"]

        @product = Product.new(:id => hash["product_id"])
        @product.fetch
        
        return true
      when '400', '401', '403'
        set_errors(response)
        return false
      else
        return false
      end      
    end
  
    def reissue
      @errors.clear
      return false unless valid?
      
      params = { 
        "id"             => @id,
        "csr"            => @csr_code,
        "dcv_method"     => @dcv_method,
        "webserver_type" => @webserver_type
      }
      
      if @dcv_method == "email" && @product.validation == "dv"
        email_params = {
          "approver_email" => @approver_email
        }
        params.merge!(email_params)
      
        if @product.multi_domain
          multi_domain_params = {
            "dns_names"       => @domains,
            "approver_emails" => @approver_emails
          }
          params.merge!(multi_domain_params)
        end
      end
      
      request = Client.post('/certificates/reissue', params)
      
      case response.code
      when '200'  
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
