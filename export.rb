# frozen_string_literal: true

# Class to store export type data and export connection data
class Export
  attr_reader :connection
  attr_reader :export_function

  def initialize(connection, export_function)
    @connection = connection
    @export_function = export_function
  end
end