# GlobeSSL Client
The **GlobeSSL Client** is a Ruby API client for GlobeSSL CA resellers. This client provides almost all of the functionality exposed by version 2 of their API. To use this client you will need an API key.

## Background
The **GlobeSSL Client** is an opinionated client library for the GlobeSSL CA API. We built this library to provide fully automated provisioning of SSL Certificates for our client's apps and websites using the Brightcommerce API.

The **GlobeSSL Client** provides endpoint access to the API methods that fulfill our requirements. It is very important to us that integration with GlobeSSL CA is seamless and provides as few touch-points as possible with the end-user. For instance, for the domain validation method we use the 'http' method which permits us to prove ownership of a domain by providing a specific text file at a specific URL. This means the end-user doesn't have to click a link in an email and punch in a code to validate ownership of a domain. We also use their autocsr method to generate the Certificate Signing Request and Private Key, rather than shell out and use OpenSSL.

The **GlobeSSL Client** has undergone extensive real-world testing with real certificates. We worked closely with the CTO from GlobeSSL CA to address any issues or suggestions we had with their API. The assistance we received was truly excellent, and we're happy to provide this library to the public domain, which we hope will only mean more resellers for them.

## About GlobeSSL CA
To find out more about GlobeSSL CA please visit their [website](https://www.globessl.com). You can find out more about the API by reading their [documentation](https://api.globessl.com/docs/). To use their API you need to have a reseller account, you can find out more about their reseller plans at the [strategic partners](https://www.globessl.com/strategic-partners/) page on their website.

## Installation
To install add the line to your `Gemfile`:
```bash
gem 'globessl'
```
And call `bundle install`.

Alternatively, you can install it from the terminal:
```bash
gem install globessl
```

## Dependencies
**GlobeSSL Client** has the following runtime dependencies:
- Virtus ~> 1.0.3

## Compatibility
Developed with MRI 2.2, however the `.clientspec` only specifies MRI 2.0. It may work with other flavors, but it hasn't been tested. Please let us know if you encounter any issues.

## How To Use

### Prerequisites
**GlobeSSL Client** requires an API key. By default the library will look for your API key in the environment variable `GLOBESSL_API_KEY`. If you'd like to override this and provide the API key directly to the API, setup a configuration initializer as shown below:
```ruby
GlobeSSL.configure do |config|
  config.api_key = "b04b4e74c57c37de48863ef9373963e0b496f5e7" # fictional
end
```

You can access any configuration settings directly on the GlobeSSL namespace:
```ruby
api_key = GlobeSSL.api_key #=> b04b4e74c57c37de48863ef9373963e0b496f5e7
api_url = GlobeSSL.api_url #=> https://api.globessl.com/v2
```

### API Calls
The **GlobeSSL Client** provides access to the following GlobeSSL CA API endpoints:
- [account/balance](https://api.globessl.com/docs/#api-account-balance) Retrieves your reseller account balance.
- [account/details](https://api.globessl.com/docs/#api-account-details) Retrieves your reseller account details.
- [products/list](https://api.globessl.com/docs/#api-products-list) Returns a detailed list of all available SSL Certificate products.
- [products/details](https://api.globessl.com/docs/#api-products-details) Returns single product's details.
- [tools/webservers](https://api.globessl.com/docs/#api-tools-webservers) Returns an array with available web server types.
- [tools/domainemails](https://api.globessl.com/docs/#api-tools-getdomainemails) Returns an array with available domain validation email addresses.
- [tools/autocsr](https://api.globessl.com/docs/#api-tools-autocsr) Returns a private key and certificate signing request.
- [tools/decodecsr](https://api.globessl.com/docs/#api-tools-decodescr) Validates submitted CSR code. Returns parsed data in array.
- [order/ssl](https://api.globessl.com/docs/#api-order-ssl) Order a new SSL Certificate.
- [certificates/get](https://api.globessl.com/docs/#api-certificates-get) Retrieve a single SSL Certificate.
- [certificates/reissue](https://api.globessl.com/docs/#api-certificates-reissue) Reissue a single certificate.
- [dcv/change](https://api.globessl.com/docs/#api-dcv-change) Change DCV Method for SSL Certificate.
- [dcv/resend](https://api.globessl.com/docs/#api-dcv-resend) Re-sends validation email for the SSL Certificate.

**GlobeSSL Client** does not provide access the following GlobeSSL CA API endpoint:
- [order/quick](https://api.globessl.com/docs/#api-order-quickssl) Order a new SSL Certificate using invite method. The client will receive the URL for completing the SSL generation.

## How To Use
We've attempted to make the **GlobeSSL Client** interface as consistent as possible. The GlobeSSL CA API has the following rules:
- `GET` requests require any parameters in the URL.
- `POST` requests require any parameters as `x-www-form-urlencoded` and passed in the request body.
- The resellers API key is passed in the `X-API-KEY` header.
- All responses including errors are returned in the `body` and are encoded as `JSON`.

The **GlobeSSL Client** breaks the API into consistent logical domain models. The models are backed by Virtus Model and most provide a `#fetch` method. Where a model performs a specific action the method will be named, and the parameters for the model must be provided as attributes on the class. Every call performs some validation before executing the API call. If the validation fails, the call will return `false` and any exceptions are made available in the `#errors` collection attribute.

Following are examples of how to instantiate each class with attributes where necessary, and the properties that can be queried on the class after each API call. All example information including names, addresses and other details are completely fictional and provided to give context.

### Account Balance
```ruby
@account = GlobeSSL::AccountBalance.new

result = @account.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @account.errors.each do |err|
    puts err
  end
end

# AccountBalance properties
@account.balance #=> 1234.56
@account.currency #=> 'USD'
```

### Account Details
```ruby
@account = GlobeSSL::AccountDetails.new

result = @account.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @account.errors.each do |err|
    puts err
  end
end

# AccountDetails properties
@account.account_id #=> 9999
@account.balance #=> 1234.56
@account.total_balance #=> 1234.56
@account.account_type #=> 29
@account.email #=> support@acmecerts.com
@account.name #=> Richard Reseller
@account.company #=> Acme SSL Certs
@account.address #=> 123 Fourth Street
@account.city #=> Fivetown
@account.state # South Sixly
@account.country # US
@account.postal_code #=> 12345-6789
```

### Products
```ruby
@products = GlobeSSL::Products.new

result = @products.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @products.errors.each do |err|
    puts err
  end
end

@products.list #=> an enumerable array of GlobeSSL::Product
@products.list.size #=> 39

# Enumerate each
@products.list.each do |prod|
  puts prod.name
end

# Product properties
prod = @products.list.first
prod.is_a?(GlobeSSL::Product) #=> true
prod.id #=> 106
prod.name #=> Globe FREE SSL
prod.validation #=> dv
prod.wildcard #=> false
prod.mdc #=> false
prod.mdc_min #=> 0
prod.mdc_max #=> 0
prod.brand #=> Globe SSL

# You can also request a single product like so:
@product = GlobeSSL::Product.new(:id => 106)
result = @product.fetch #=> true
@product.is_a?(GlobeSSL::Product) #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @product.errors.each do |err|
    puts err
  end
end
```

### Webservers
```ruby
@webservers = GlobeSSL::Webservers.new

result = @webservers.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @webservers.errors.each do |err|
    puts err
  end
end

@webservers.list #=> an enumerable array of GlobeSSL::Webserver
@webservers.list.size #=> 37

# Enumerate each
@webservers.list.each do |ws|
  puts "#{ws.id.to_s}: #{ws.name}"
end

# Webserver properties
webserver = @webservers.list.first
webserver.is_a?(GlobeSSL::Webserver) #=> true
webserver.id #=> 1
webserver.name #=> AOL
```

### Domain Emails
```ruby
@domain_emails = GlobeSSL::DomainEmails.new(:domain => "acmecerts.com")

result = @domain_emails.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @domain_emails.errors.each do |err|
    puts err
  end
end

@domain_emails.list #=> an array of email addresses
@domain_emails.list.size #=> 5

# Enumerate each
@domain_emails.list.each do |email|
  puts email
end

# DomainEmail properties
email = @domain_emails.list.first #=> admin@acmecerts.com
email.is_a?(String) #=> true
```

### Certificate Signing Request (CSR)
```ruby
@csr = GlobeSSL::CertificateSigningRequest.new(
  :country_name             => "US",
  :state_or_province_name   => "South Sixly",
  :locality_name            => "Fivetown",
  :organization_name        => "Acme SSL Certs",
  :organizational_unit_name => "acmecerts.com",
  :common_name              => "www.acmecerts.com",
  :email_address            => "support@acmecerts.com"
 )

result = @csr.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @csr.errors.each do |err|
    puts err
  end
end

# CSR properties
@csr.private_key #=> -----BEGIN PRIVATE KEY-----\nMIIEv...
@csr.csr_code #=> -----BEGIN CERTIFICATE REQUEST-----\nMIIC/j...
@csr.fingerprint_sha1 #=> 42153B1CE...
@csr.fingerprint_md5 #=> AA24D856...

# Decoding the CSR
result = @csr.decode #=> true
@csr.decoded_csr #=> {"CN":"www.acmecerts.com","OU":"acmecerts.com"...
```

### Order SSL Certificate
```ruby
@order = GlobeSSL::OrderSSLCertificate.new(
  :admin_firstname       => "Richard",
  :admin_lastname        => "Reseller",
  :admin_email           => "admin@acmecerts.com",
  :admin_phone           => "9995557856",
  :admin_org             => "Acme SSL Certs", # optional
  :admin_jobtitle        => "Administrator", # optional
  :admin_address         => "123 Fourth Street", # optional
  :admin_city            => "Fivetown", # optional
  :admin_country         => "US", # optional
  :optional_admin_params => true,
  :cert_signing_request  => @csr, # CertificateSigningRequest object
  :dcv_method            => "email",
  :period                => 0,
  :product               => @product, # Product object
  :webserver_type        => 36, # nginx
  :approver_email        => "admin@acmecerts.com"
)

result = @order.purchase! #=> true

# If the purchase! method fails it will return false and populate the errors collection attribute:
if result == false
  @order.errors.each do |err|
    puts err
  end
end

# Order properties
@order.order_id #=> 99999
@order.certificate_id #=> 303030
@order.amount #=> 0
@order.currency #=> USD
```

### SSL Certificate
```ruby
@cert = GlobeSSL::SSLCertificate.new(
  :id => @order.certificate_id # from above
)

result = @cert.fetch #=> true

# If the fetch method fails it will return false and populate the errors collection attribute:
if result == false
  @cert.errors.each do |err|
    puts err
  end
end

# Certificate properties
@cert.order_id #=> 99999
@cert.partner_order_id #=> 865231756
@cert.status #=> Active
@cert.status_description #=> Active
@cert.dcv_method #=> email
@cert.dcv_email #=> admin@acmecerts.com
@cert.product #=> GlobeSSL::Product
@cert.domain #=> www.acmecerts.com
@cert.domains #=> array of domains if multi-domain product
@cert.total_domains #=> 1
@cert.period #=> 1 (year)
@cert.valid_from #=> 2015-10-06
@cert.valid_till #=> 2015-11-06
@cert.csr_code #=> -----BEGIN CERTIFICATE REQUEST-----\nMIIC/j...
@cert.crt_code #=> -----BEGIN CERTIFICATE-----\nMIIFdT...
@cert.ca_code #=> -----BEGIN CERTIFICATE-----\nMIIGBzCC...
```

### Domain Control Validation
```ruby
@dcv = GlobeSSL::DomainControlValidation.new(
  :certificate => cert, # from above
  :dcv_method  => 'email'
)

# Resend the domain control validation email:
result = @dcv.resend! #=> true

# Change the domain control validation method:
@dcv.method = 'http' # see GlobeSSL::DomainControlValidation::METHODS
@dcv.approver_email = "administrator@acmecerts.com"
result = @dcv.change! #=> true

# If the resend! or change! method fails it will return false and populate the errors collection attribute:
if result == false
  @dcv.errors.each do |err|
    puts err
  end
end
```

### Country Codes
The **GlobeSSL Client** provides a constant hash of country codes. This list is derived from https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2. The hash keys are ISO_3166-1_alpha-2 codes and the values are the country display name. The top 20 countries by number of Internet users are grouped first, see  https://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users.

Example: access a country name by code:
```ruby
GlobeSSL::COUNTRY_CODES['US'] #=> United States
```
All the regular hash functions are available for find keys and values, but the hash is immutable. If you want to manipulate the list, for example to sort it differently; you will have to copy it into a new hash variable first.

## Testing
GlobeSSL CA do not provide a test environment for their API. This is understandable since SSL Certificates are issued by Certificate Authorities. Everything about the API is about generating an SSL Certificate, so it stands to reason that a test environment would be quite difficult to create and support.

However, they do provide a way for resellers to use the API in a test capacity by allowing you to generate a `**FREE**` certificate. The certificate generated is a real working certificate, but it has a 3 month expiry date. The `product_id` for this certificate is `106`.

You will need to check if the product is returned by the `GlobeSSL::Products` class. If the product isn't in the list then contact GlobeSSL CA to request the product be enabled. I have been informed that the product is purely for test scenarios and abuse is monitored. Abusive behavior will result in the product being removed from your account.

## To Do
- Document extended validation (`ev`) and organizational validation (`ov`) certificate type info supported in `GlobeSSL::OrderSSLCertificate`.
- Document `dns_names` and `approver_emails` for multi-domain certificate types supported in `GlobeSSL::OrderSSLCertificate`.
- Add `http` and `https` domain control validation method (`dcv_method`) documentation.
- Test suite with mocks for CI/CD scenarios.

## Acknowledgements
#### Version 1.0.0
- Jurgen Jocubeit - President & CEO, [Brightcommerce, Inc.](http://brightcommerce.com)
- Zoltan Egresi - CTO, [GlobeSSL CA](https://globessl.com) (API guidance and live testing assistance)

## License
This library is release in the public domain under the [MIT License](http://opensource.org/licenses/MIT).

## Copyright
Copyright 2015 Brightcommerce, Inc.
All rights reserved.
