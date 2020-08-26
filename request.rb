# frozen_string_literal: true

require 'httparty'
require 'json'

# Class to handel requests to Pipedrive api and return results as list of Pipedrive Objects
class Request
  DEAL_HEADERS = %w[title org_name person_name formatted_value currency status expected_close_date].freeze
  PRODUCT_HEADERS = %w[name code description unit tax category prices].freeze
  ACTIVITY_HEADERS = %w[subject type due_date due_time duration public_description location_formatted_address note].freeze
  LEAD_HEADERS = %w[title expected_close_date value note].freeze
  PERSON_HEADERS = %w[name open_deals_count closed_deals_count participant_open_deals_count participant_closed_deals_count].freeze

  # Handles request to get deals from Pipedrive API
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  # @return [Array<Hash>] a list of the Pipedrive deal object data hashed with DEAL_HEADERS values as keys
  def self.deals(connection)
    data = request_data(connection, '/deals')

    deals_fields = request_data(connection, '/dealFields')
    field_full_names = {}
    deals_fields.each { |field| field_full_names[field['key']] = field['name'] }

    deals = []
    data.each do |deal_data|
      deals << extract_data(DEAL_HEADERS, field_full_names, deal_data)
    end
    deals
  end

  # Handles request to get products from Pipedrive API
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  # @return [Array<Hash>] a list of the Pipedrive product object data hashed with PRODUCT_HEADERS values as keys
  def self.products(connection)
    data = request_data(connection, '/products')

    products_fields = request_data(connection, '/productFields')
    field_full_names = {}
    products_fields.each { |field| field_full_names[field['key']] = field['name'] }

    products = []
    data.each do |product_data|
      products << extract_data(PRODUCT_HEADERS, field_full_names, product_data)
    end
    products
  end

  # Handles request to get activities from Pipedrive API
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  # @return [Array<Hash>] a list of the Pipedrive activity object data hashed with PRODUCT_HEADERS values as keys
  def self.activities(connection)
    data = request_data(connection, '/activities')

    activities_fields = request_data(connection, '/activityFields')
    field_full_names = {}
    activities_fields.each { |field| field_full_names[field['key']] = field['name'] }

    activities = []
    data.each do |activity_data|
      activities << extract_data(ACTIVITY_HEADERS, field_full_names, activity_data)
    end
    activities
  end

  # Handles request to get leads from Pipedrive API
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  # @return [Array<Hash>] a list of the Pipedrive lead object data hashed with ACTIVITY_HEADERS values as keys
  def self.leads(connection)
    data = request_data(connection, '/leads')

    leads_fields = request_data(connection, '/leadFields')
    field_full_names = {}
    leads_fields.each { |field| field_full_names[field['key']] = field['name'] }

    leads = []
    data.each do |lead_data|
      leads << extract_data(LEAD_HEADERS, field_full_names, lead_data)
    end
    leads
  end

  # Handles request to get persons from Pipedrive API
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  # @return [Array<Hash>] a list of the Pipedrive person object data hashed with PERSON_HEADERS values as keys
  def self.persons(connection)
    data = request_data(connection, '/persons')

    persons_fields = request_data(connection, '/personFields')
    field_full_names = {}
    persons_fields.each { |field| field_full_names[field['key']] = field['name'] }

    persons = []
    data.each do |person_data|
      persons << extract_data(PERSON_HEADERS, field_full_names, person_data)
    end
    persons
  end

  # Extracts only the data given in the header from the data file
  # @param headers [Array<String>] list of headers for data to extract from the Pipedrive data object
  # @param data [Hash] the Pipedrive data object as a Hash
  # @return [Hash] a hash with header values as keys to data
  def self.extract_data(headers, field_full_names, data)
    new_data = {}

    headers.each { |header| new_data[field_full_names[header] ? field_full_names[header] : header] = data[header] }
    new_data
  end

  # Builds the url to make requests to the Pipedrive API
  # @param company_domain [String] the company domain to connect to Pipedrive API
  # @param end_point [String] the Pipedrive API endpoint to build query url for
  # @param params [Hash] any params to add to the query url
  # @return [String] the url to make query to Pipedrive API with the given info
  def self.build_url(company_domain, end_point, params)
    url = "https://#{company_domain}.pipedrive.com/v1#{end_point}"
    # Loop over params and add to url
    params.each_with_index do |(key, value), i|
      url += "#{i.zero? ? '?' : '&'}#{key}=#{value}"
    end
    url
  end

  # Makes the request to the Pipedrive API to get the desired data
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  # @param end_point [String] the Pipedrive API endpoint to build query url for
  # @return [Array<Hash>] a list of the JSON parsed query response body data
  def self.request_data(connection, end_point)
    # Start at 0 keep track of page_start in case several requests are needed to get all data
    page_start = 0

    data = []
    #  Loop while there are more items in collection
    loop do
      params = {
        start: page_start.to_s,
        api_token: connection.api_token
      }
      url = build_url(connection.company_domain, end_point, params)
      response = HTTParty.get(url)

      # Handel if response is unsuccessful
      unless response['success']
        puts "Error #{response['errorCode']}: #{response['error']}"
        # If error due to x-ratelimit-limit wait 2 sec and retry
        if response['errorCode'] == 429
          sleep(2)
          next
        end
      end

      json_response = JSON.parse(response.body)
      # Add data to data array if exists
      data.concat(json_response['data']) if json_response['data']

      # Check if there are more items in collection
      pagination_info = json_response['additional_data']['pagination']
      break unless pagination_info['more_items_in_collection']

      # Update page_start to get more items next iteration
      page_start = pagination_info['start'] + pagination_info['limit']
    end
    data
  end
end
