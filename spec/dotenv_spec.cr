# spec/dotenv_spec.cr
require "./spec_helper"
require "file_utils"

describe Dotenv do
  after_each do
    # Clean up test files
    ["test.env", "test2.env"].each do |file|
      File.delete(file) if File.exists?(file)
    end

    # Clean up environment
    ["TEST_KEY", "TEST_EMPTY", "TEST_QUOTED"].each do |key|
      ENV.delete(key) if ENV.has_key?(key)
    end
  end

  describe ".load" do
    it "loads basic key-value pairs" do
      File.write("test.env", "TEST_KEY=test_value\n")

      result = Dotenv.load("test.env")

      result["TEST_KEY"].should eq("test_value")
      ENV["TEST_KEY"].should eq("test_value")
    end

    it "handles empty values" do
      File.write("test.env", "TEST_EMPTY=\n")

      result = Dotenv.load("test.env")

      result["TEST_EMPTY"].should eq("")
      ENV["TEST_EMPTY"].should eq("")
    end

    it "loads from multiple files using array" do
      File.write("test.env", "KEY1=value1\n")
      File.write("test2.env", "KEY2=value2\n")

      result = Dotenv.load(["test.env", "test2.env"])

      result["KEY1"].should eq("value1")
      result["KEY2"].should eq("value2")
    end

    it "loads from multiple files using load_multiple" do
      File.write("test.env", "KEY1=value1\n")
      File.write("test2.env", "KEY2=value2\n")

      result = Dotenv.load_multiple("test.env", "test2.env")

      result["KEY1"].should eq("value1")
      result["KEY2"].should eq("value2")
    end
  end
end
