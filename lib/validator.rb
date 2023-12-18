
module Validator

  CONFIG_SCHEMA = {
    "type" => "object",
    "properties" => {
      "sources" => {
        "type" => "object",
        "patternProperties" => {
          ".*" => {
            "type" => "object",
            "properties" => {
              "repo" => { "type" => "string" },
              "branch" => { "type" => "string" }
            },
            "required" => ["repo"]
          }
        }
      },
      "tasks" => {
        "type" => "object",
        "patternProperties" => {
          ".*" => {
            "type" => "object",
            "properties" => {
              "description" => { "type" => "string" },
              "pre_condition" => { "anyOf" => [{ "type" => "array" }, { "type" => "string" }] },
              "execute" => { "anyOf" => [{ "type" => "array" }, { "type" => "string" }] },
              "comparator" => { "type" => "string" },
              "report" => { "type" => "string" },
              "publish_header" => { "type" => "array" }
            },
            "required" => ["execute"]
          }
        }
      },
      "comparator_agregator" => { "type" => "string" }
    },
    "required" => ["tasks"]
  }.freeze

  def self.validate_config(data, schema)
    validate_object(data, schema, [])
  end

  def self.validate_object(obj, schema, path)
    return [] unless obj.is_a?(Hash) && schema["type"] == "object"

    errors = []

    # Validate required properties
    (schema["required"] || []).each do |prop|
      unless obj.key?(prop)
        errors << "Property '#{prop}' is required at '#{path.join(' => ')}'"
      end
    end

    # Validate properties
    (schema["properties"] || {}).each do |prop, prop_schema|
      next unless obj.key?(prop)

      value = obj[prop]
      errors += validate_value(value, prop_schema, path + [prop])
    end

    # Validate patternProperties
    (schema["patternProperties"] || {}).each do |pattern, pattern_schema|
      (obj.keys.select { |prop| prop.match?(Regexp.new(pattern)) } || []).each do |prop|
        value = obj[prop]
        errors += validate_value(value, pattern_schema, path + [prop])
      end
    end

    # Check for additional properties not defined in the schema
    unexpected_properties = obj.keys - (schema["properties"] || {}).keys
    unexpected_properties -= (schema["patternProperties"] || {}).keys.flat_map { |pattern| obj.keys.select { |prop| prop.match?(Regexp.new(pattern)) } }
    unless unexpected_properties.empty?
      errors << "Unexpected properties #{unexpected_properties} found at '#{path.join(' => ')}'"
    end

    errors
  end

  def self.validate_array(arr, schema, path)
    return [] unless arr.is_a?(Array) && schema["type"] == "array"

    errors = []

    arr.each_with_index do |item, index|
      errors += validate_object(item, schema["items"], path + [index.to_s])
    end

    errors
  end

  def self.validate_value(value, schema, path)
    case schema["type"]
    when "object"
      validate_object(value, schema, path)
    when "array"
      validate_array(value, schema, path)
    when "string", "number", "boolean"
      unless value.is_a?(eval(schema["type"].capitalize))
        ["Value at '#{path.join(' => ')}' should be of type #{schema['type']}, but found #{value.class}"]
      else
        []
      end
    else
      handle_any_of(value, schema["anyOf"], path)
    end
  end

  def self.handle_any_of(value, any_of_schemas, path)
    errors = []

    unless any_of_schemas.any? { |subschema| validate_value(value, subschema, path).empty? }
      errors << "Value at '#{path.join(' > ')}' does not match anyOf schemas"
    end

    errors
  end

  def self.validate_configuration_file(file_path)
    begin
      data = JSON.parse(File.read(file_path))

      errors = validate_config(data, CONFIG_SCHEMA)

      if errors.empty?
        config = JSON.parse(File.read(file_path), symbolize_names: true)
        return config
      else
        str = "\n - " + errors.join("\n - ")
        raise Ex::InvalidConfigFileException.new(File.basename(file_path), str)
      end

    rescue JSON::ParserError
      raise Ex::InvalidJSONFormatException.new(File.basename(file_path))
    end
  end
end