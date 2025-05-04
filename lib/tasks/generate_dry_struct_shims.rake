# typed: false

desc 'Generate Sorbet shim RBI files for Dry::Structs with type inference'
task :generate_dry_struct_shims do
  require 'parser/current'
  require 'fileutils'
  require 'active_support/inflector'

  def extract_const_name(node)
    return nil unless node.is_a?(Parser::AST::Node)

    case node.type
    when :const
      parent = extract_const_name(node.children[0])
      current = node.children[1].to_s
      parent ? "#{parent}::#{current}" : current

    when :send
      receiver = extract_const_name(node.children[0])
      method = node.children[1].to_s
      args = node.children[2..].map { |arg| extract_const_name(arg) }.compact
      "#{receiver}.#{method}(#{args.join(', ')})"

    when :sym
      node.children[0].to_s

    end
  end

  def map_type_to_sig(type)
    case type
    when 'Types::String'                then 'String'
    when 'Types::Integer', 'Types::Int' then 'Integer'
    when 'Types::Float'                 then 'Float'
    when 'Types::Decimal'               then 'BigDecimal'
    when 'Types::Bool'                  then 'T::Boolean'
    when 'Types::Date'                  then 'Date'
    when 'Types::Time', 'Types::Params::Time' then 'Time'
    when 'Types::Array'                 then 'T::Array[T.untyped]'
    when 'Types::Hash'                  then 'T::Hash[T.untyped, T.untyped]'
    when 'Types::Nil'                   then 'NilClass'
    when 'Types::Symbol'                then 'Symbol'
    else 'T.untyped'
    end
  end

  puts 'Scanning app/ for Dry::Structs...'

  Dir.glob('app/**/*.rb').each do |file_path|
    source = File.read(file_path)
    buffer = Parser::Source::Buffer.new(file_path)
    buffer.source = source
    parser = Parser::CurrentRuby.new
    ast = parser.parse(buffer)
    next unless ast

    class_node = ast if ast.type == :class
    class_node ||= ast.children.find { |child| child.is_a?(Parser::AST::Node) && child.type == :class }
    next unless class_node

    class_name_node = class_node.children[0]
    superclass_node = class_node.children[1]
    body_node = class_node.children[2]
    next unless superclass_node

    full_superclass = extract_const_name(superclass_node)
    puts full_superclass
    next unless full_superclass == 'Dry::Struct'

    const_parts = []
    while class_name_node
      break unless class_name_node.type == :const

      const_parts.unshift(class_name_node.children[1])
      class_name_node = class_name_node.children[0]

    end
    class_name = const_parts.join('::')
    filename = class_name.underscore

    attributes = []
    nodes_to_check = body_node&.type == :begin ? body_node.children : [body_node]
    nodes_to_check.compact.each do |node|
      next unless node.is_a?(Parser::AST::Node)
      next unless node.type == :send && node.children[1] == :attribute

      sym_node = node.children[2]
      attr_name = sym_node.type == :sym ? sym_node.children[0].to_s : nil
      next unless attr_name

      type_name = extract_const_name(node.children[3]) || 'T.untyped'
      attributes << [attr_name.to_s, map_type_to_sig(type_name)]
    end

    next if attributes.empty?

    shim_path = File.join('sorbet', 'rbi', 'shims', "#{filename}.rbi")
    puts "Generating #{shim_path}"
    FileUtils.mkdir_p(File.dirname(shim_path))

    File.open(shim_path, 'w') do |f|
      f.puts "# typed: true\n\nclass #{class_name}"
      attributes.each_with_index do |(attr, type), index|
        f.puts "  sig { returns(#{type}) }"
        f.puts "  def #{attr}; end"
        f.puts '' unless index == attributes.size - 1
      end
      f.puts 'end'
    end
  end

  puts 'Done'
end
