module GlobeSSL
  class DomainControlValidation < Base
    METHODS = ["email", "http", "https"].freeze

    attribute :certificate,     SSLCertificate
    attribute :dcv_method,      String
    attribute :approver_email,  String
    attribute :approver_emails, String
    
    def change!
      @errors.clear
      
      return false unless valid?
      
      params = { 
        "id"         => @certificate.id,
        "dcv_method" => @dcv_method
      }
      
      if @dcv_method == "email" && @certificate.product.validation == "dv"
        email_params = {
          "approver_email" => @approver_email
        }
        params.merge!(email_params)
        
        if @certificate.product.multi_domain
          multi_domain_params = {
            "approver_emails" => @approver_emails
          }
          params.merge!(multi_domain_params)
        end
      end
            
      request = Client.post('/dcv/change', params)
      
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
    
    def resend!
      @errors.clear
      
      unless @certificate
        @errors << "certificate is required"
        return false
      end
      
      params = { 
        "id" => @certificate.id
      }
      
      request = Client.post('/dcv/resend', params)
      
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
      unless @certificate
        @errors << "certificate is required"
      end
      
      unless @dcv_method
        @errors << "dcv_method is required"
      else
        unless METHODS.include?(@dcv_method)
          @errors << "dcv_method must be one of 'email', 'http' or 'https'"
        end
      end
      
      if @dcv_method == "email"
        unless @approver_email
          @errors << "approver_email is required"
        end
        
        if @certificate.product.multi_domain
          unless @approver_emails
            @errors << "approver_emails are required"
          end
        end
      end
      
      if @errors.any?
        return false
      else
        return true
      end
    end
    
    def self.write_file(sha1, md5, location)
      File.open(File.join(location, "#{md5}.txt"), 'w') do |file|
        file.puts sha1
        file.puts "comodoca.com"
      end
    end
  end
end
