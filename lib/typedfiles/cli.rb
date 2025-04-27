# frozen_string_literal: true

require "fileutils"
require "active_support/core_ext/string/inflections"
require "optparse"

module Typedfiles
  class CLI
    GREEN = "\e[32m"
    RED = "\e[31m"
    RESET = "\e[0m"

    def initialize(args)
      @options = {}
      parse_options!(args)
    end

    def run
      if @path.nil?
        puts "#{RED} Please provide a file path! Example: services/users/signup_service#{RESET}"
        exit(1)
      end

      # Ensure .rb extension
      @path += ".rb" unless @path.end_with?(".rb")

      file_path = "app/#{@path}"

      # Create directories if needed
      FileUtils.mkdir_p(File.dirname(file_path))

      if File.exist?(file_path)
        puts "#{RED} File already exists: #{file_path}#{RESET}"
        exit(1)
      end

      # Determine module and class names
      path_without_ext = @path.gsub(".rb", "")
      constant_name = path_without_ext.camelize

      module_names = @options[:module] || constant_name.deconstantize
      class_name = constant_name.demodulize

      # Create the file
      File.open(file_path, "w") do |file|
        file.puts "# typed: strict"
        file.puts
        file.puts "module #{module_names}" unless module_names.empty?
        file.puts "  class #{class_name}"
        file.puts "    extend T::Sig"
        file.puts
        file.puts "    sig { void }"
        file.puts "    def initialize"
        file.puts "    end"
        file.puts
        file.puts "    sig { returns(T.untyped) }"
        file.puts "    def call"
        file.puts "      # TODO: Implement logic"
        file.puts "    end"
        file.puts "  end"
        file.puts "end" unless module_names.empty?
      end

      puts "#{GREEN} File created successfully: #{file_path}#{RESET}"
    end

    private

    def parse_options!(args)
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: typedfiles path/to/file [options]"

        opts.on("--module=MODULE", "Specify the module name manually") do |mod|
          @options[:module] = mod
        end
      end

      non_options, options = args.partition { |arg| !arg.start_with?("--") }
      @path = non_options.first
      option_parser.parse!(options)
    end
  end
end
