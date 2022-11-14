# frozen_string_literal: true

module YARD
  module Handlers
    module JRuby
      module Base
        class << self
          def infer_java_class(klass, inferred_type = nil, comments = nil, statement = nil)
            class_first_char = klass.split(".").last[0]
            is_package = class_first_char != class_first_char.upcase

            javadocs = YARD::Config.options.dig(:jruby, "javadocs") || {}

            href_base = javadocs.find { |package, _href| klass.start_with?(package) }&.last
            return unless href_base

            inferred_type = CodeObjects::Java::PackageObject if is_package
            if inferred_type.nil?
              docstring = Docstring.parser.parse(comments || statement&.comments).to_docstring
              inferred_type = if docstring.has_tag?(:interface)
                                CodeObjects::Java::InterfaceObject
                              else
                                CodeObjects::Java::ClassObject
                              end
            end

            inferred_type.new(klass) do |o|
              o.source = statement if statement
              suffix = "/package-summary" if is_package
              link = "#{href_base}#{klass.tr(".", "/")}#{suffix}.html"
              o.docstring.add_tag(Tags::Tag.new(:see, klass, nil, link)) unless o.docstring.has_tag?(:see)
            end
          end
        end

        def infer_java_class(statement, inferred_type = nil, comments = nil)
          return unless statement.is_a?(Parser::Ruby::AstNode)
          return unless statement.type == :call

          Base.infer_java_class(statement.source, inferred_type, comments, statement)
        end
      end
    end
  end
end
