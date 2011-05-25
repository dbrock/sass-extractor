require "fileutils"
require "sass"

class SassExtractor
  def initialize(options)
    @options = options
  end

  def get_rules(file_name)
    Extractor.new(sass_tree_for_file(file_name)).get_rules(prefixes)
  end

  def sass_tree_for_file(file_name)
    Sass::Engine.for_file(file_name, sass_options).to_tree
  end

  def sass_options; @options[:sass_options] end
  def prefixes; @options[:prefixes] || [""] end

  class Extractor
    def initialize(tree)
      @tree = tree
      compile
    end

    def get_rules(prefixes)
      Visitor.visit(@tree, prefixes)
    end

    def compile
      check_nesting
      @tree = Sass::Tree::Visitors::Perform.visit(@tree)
      check_nesting
      @tree, extends = Sass::Tree::Visitors::Cssize.visit(@tree)
      @tree = @tree.do_extend(extends) unless extends.empty?
    end

    def check_nesting
      Sass::Tree::Visitors::CheckNesting.visit(@tree)
    end
  end

  class Visitor < Sass::Tree::Visitors::Base
    def self.visit(root, prefixes)
      new(prefixes).send(:visit, root)
    end

    def initialize(prefixes)
      @prefixes = prefixes
    end

    def visit_root(node)
      yield.compact
    end

    def visit_directive(node)
    end

    def visit_rule(node)
      selector = node.resolved_rules.to_a.join.gsub(/\s+/, " ")
      properties = extract_properties(node)
      [selector, properties] unless properties == {}
    end

    def extract_properties(rule)
      build_hash do |result|
        each_property(rule) do |name, value|
          result[name] = value if interesting? name
        end
      end
    end
  
    def build_hash
      result = {}; yield result; result
    end

    def each_property(rule)
      rule.children.each do |property|
        yield property.resolved_name, property.resolved_value
      end
    end

    def interesting?(name)
      @prefixes.any? { |prefix| name.start_with? prefix }
    end
  end
end
