# Programming Exercise
## Requirements
```
gem install httparty
```
## Export codes
```
'export_deals'
'export_products'
'export_activities'
'export_leads'
'export_persons'
```
## Example
```
require_relative 'connection'
require_relative 'export'
require_relative 'csv_exporter'

my_domain = 'my_domain_goes_here'
my_api_token = 'my_api_token_goes_here'

my_connection = Connection.new(my_domain, my_api_token)

my_exports = []
my_exports << Export.new(my_connection, 'export_deals')
my_exports << Export.new(my_connection, 'export_products')
my_exports << Export.new(my_connection, 'export_activities')
my_exports << Export.new(my_connection, 'export_leads')
my_exports << Export.new(my_connection, 'export_persons')

my_exports.each { |export| CSVExporter.execute(export)}

```