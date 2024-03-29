# frozen_string_literal: true

require_relative 'request'
require 'csv'

# Class to execute Export object and write CSV file from Pipedrive data
class CSVExporter
  @directory_name = 'export_data'

  # Runs the function to export the data specified in the Export object
  # @param export [Export] the Export object containing information on the export job
  def self.execute(export)
    # Make a separate directory for CSV files if does not exist
    Dir.mkdir @directory_name unless File.exist?(@directory_name)

    # Run the export function for the Pipedrive object specified in the Export
    send(export.export_function, export.connection)
  end

  # Writes the given data to the given csv file
  # @param csv_file [CSV] the opened csv file to write to
  # @param data [Hash] the data to write to the csv file
  def self.write_to_csv(csv_file, data)
    return if data.empty?

    # Write csv file headers
    headers = []
    # Format headers
    data.first.keys.each do |header|
      # Capitalize and change '_' to ' '
      header = header.capitalize()
      formatted_header = header.gsub! '_', ' '
      # If no changes made keep original header
      formatted_header = formatted_header ? formatted_header : header
      headers << formatted_header
    end
    csv_file << headers
    # Write data to csv file
    data.each do |data_object|
      csv_file << data_object.values
    end
  end

  # Requests the Pipedrive deals at given connection and writes data to CSV file
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  def self.export_deals(connection)
    deals = Request.deals(connection)
    CSV.open("#{@directory_name}/deals.csv", 'wb') do |csv|
      write_to_csv(csv, deals)
    end
  end

  # Requests the Pipedrive products at given connection and writes data to CSV file
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  def self.export_products(connection)
    products = Request.products(connection)
    product_prices = []
    products.each do |product|
      prices = product.delete('prices')
      prices.each do |price|
        price['Product Name'] = product["Name"]
        price.delete('id')
        price.delete('product_id')
      end
      product_prices.concat(prices)
    end

    CSV.open("#{@directory_name}/products.csv", 'wb') do |csv|
      write_to_csv(csv, products)
    end

    CSV.open("#{@directory_name}/product_prices.csv", 'wb') do |csv|
      write_to_csv(csv, product_prices)
    end
  end

  # Requests the Pipedrive activities at given connection and writes data to CSV file
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  def self.export_activities(connection)
    activities = Request.activities(connection)
    CSV.open("#{@directory_name}/activities.csv", 'wb') do |csv|
      write_to_csv(csv, activities)
    end
  end

  # Requests the Pipedrive leads at given connection and writes data to CSV file
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  def self.export_leads(connection)
    leads = Request.leads(connection)
    CSV.open("#{@directory_name}/leads.csv", 'wb') do |csv|
      write_to_csv(csv, leads)
    end
  end

  # Requests the Pipedrive persons at given connection and writes data to CSV file
  # @param connection [Connection] the connection object to connect to the Pipedrive API
  def self.export_persons(connection)
    persons = Request.persons(connection)
    CSV.open("#{@directory_name}/persons.csv", 'wb') do |csv|
      write_to_csv(csv, persons)
    end
  end

end
