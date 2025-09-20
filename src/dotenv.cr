# Simple, robust dotenv implementation for Crystal
module Dotenv
  VERSION = "0.1.0"

  # Load environment variables from a file
  def self.load(path = ".env", override = true) : Hash(String, String)
    load_from_file(path, override)
  end

  # Load from multiple files - fix the method signature
  def self.load(paths : Array(String), override = true) : Hash(String, String)
    result = {} of String => String
    paths.each do |path|
      result.merge!(load_from_file(path, override))
    end
    result
  end

  # Alternative method for multiple files with splat
  def self.load_multiple(*paths, override = true) : Hash(String, String)
    result = {} of String => String
    paths.each do |path|
      result.merge!(load_from_file(path, override))
    end
    result
  end

  private def self.load_from_file(path : String, override : Bool) : Hash(String, String)
    return {} of String => String unless File.exists?(path)

    hash = {} of String => String
    line_number = 0

    File.each_line(path) do |line|
      line_number += 1

      begin
        parse_line(line, hash, override)
      rescue ex : ParseError
        STDERR.puts "Warning: #{path}:#{line_number} - #{ex.message}"
      end
    end

    hash
  rescue ex : File::NotFoundError
    {} of String => String
  rescue ex : Exception
    STDERR.puts "Error loading #{path}: #{ex.message}"
    {} of String => String
  end

  private def self.parse_line(line : String, hash : Hash(String, String), override : Bool)
    # Remove leading/trailing whitespace
    line = line.strip

    # Skip empty lines and comments
    return if line.empty? || line.starts_with?('#')

    # Find first = sign (key=value)
    equals_index = line.index('=')
    raise ParseError.new("Missing '=' in line: #{line}") unless equals_index

    key = line[0...equals_index].strip
    value = line[equals_index + 1..-1]

    # Validate key
    raise ParseError.new("Empty key in line: #{line}") if key.empty?
    raise ParseError.new("Invalid key '#{key}' - must contain only letters, numbers, and underscores") unless valid_key?(key)

    # Parse value (handle quotes and escaping)
    parsed_value = parse_value(value)

    # Store in hash
    hash[key] = parsed_value

    # Set environment variable
    if !ENV.has_key?(key) || override
      ENV[key] = parsed_value
    end
  end

  private def self.parse_value(value : String) : String
    value = value.strip

    # Handle quoted values
    if value.starts_with?('"') && value.ends_with?('"')
      # Double quoted - handle escape sequences
      parse_double_quoted(value[1..-2])
    elsif value.starts_with?('\'') && value.ends_with?('\'')
      # Single quoted - literal value
      value[1..-2]
    else
      # Unquoted - remove inline comments
      comment_index = value.index('#')
      if comment_index
        value[0...comment_index].rstrip
      else
        value
      end
    end
  end

  private def self.parse_double_quoted(value : String) : String
    result = String::Builder.new
    i = 0

    while i < value.size
      char = value[i]

      if char == '\\' && i + 1 < value.size
        next_char = value[i + 1]
        case next_char
        when 'n'
          result << '\n'
        when 't'
          result << '\t'
        when 'r'
          result << '\r'
        when '\\'
          result << '\\'
        when '"'
          result << '"'
        else
          result << char
          result << next_char
        end
        i += 2
      else
        result << char
        i += 1
      end
    end

    result.to_s
  end

  private def self.valid_key?(key : String) : Bool
    key.matches?(/^[A-Za-z_][A-Za-z0-9_]*$/)
  end

  # Custom exception for parse errors
  class ParseError < Exception
  end
end
