module GlobeSSL
  autoload :AccountBalance,            'globessl/account_balance'
  autoload :AccountDetails,            'globessl/account_details'
  autoload :Base,                      'globessl/base'
  autoload :CertificateSigningRequest, 'globessl/certificate_signing_request'
  autoload :Client,                    'globessl/client'
  autoload :Configuration,             'globessl/configuration'
  autoload :DomainControlValidation,   'globessl/domain_control_validation'
  autoload :DomainEmails,              'globessl/domain_emails'
  autoload :OrderSSLCertificate,       'globessl/order_ssl_certificate'
  autoload :Product,                   'globessl/product'
  autoload :Products,                  'globessl/products'
  autoload :SSLCertificate,            'globessl/ssl_certificate'
  autoload :Version,                   'globessl/version'
  autoload :Webserver,                 'globessl/webserver'
  autoload :Webservers,                'globessl/webservers'

  @@configuration = nil
  
  def self.configure
    @@configuration = Configuration.new
    yield(configuration) if block_given?
    configuration
  end

  def self.configuration
    @@configuration || configure
  end
  
  def self.method_missing(method_sym, *arguments, &block)
    if configuration.respond_to?(method_sym)
      configuration.send(method_sym)
    else
      super
    end
  end

  def self.respond_to?(method_sym, include_private = false)
    if configuration.respond_to?(method_sym, include_private)
      true
    else
      super
    end    
  end
end
