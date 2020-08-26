# frozen_string_literal: true

require_relative 'connection'
require_relative 'export'
require_relative 'csv_exporter'

my_domain = 'chroosipuu'
my_api_token = '9a8656278d0c6f37199b1c159e4c5b68236e7b68'
my_connection = Connection.new(my_domain, my_api_token)

my_exports = []
my_exports << Export.new(my_connection, 'export_deals')
my_exports << Export.new(my_connection, 'export_products')
my_exports << Export.new(my_connection, 'export_activities')
my_exports << Export.new(my_connection, 'export_leads')
my_exports << Export.new(my_connection, 'export_persons')

my_exports.each { |export| CSVExporter.execute(export)}



