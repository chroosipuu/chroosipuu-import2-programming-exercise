# frozen_string_literal: true

# Connection class to store company domain and api token for Pipedrive API requests
class Connection
  attr_reader :company_domain
  attr_reader :api_token

  def initialize(company_domain, api_token)
    @company_domain = company_domain
    @api_token = api_token
  end
end