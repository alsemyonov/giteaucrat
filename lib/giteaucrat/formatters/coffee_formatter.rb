# coding: utf-8

require 'giteaucrat/formatters/ruby_formatter'

module Giteaucrat
  module Formatters
    class CoffeeFormatter < RubyFormatter
      def include_encoding?
        false
      end

      def add_copyright!
        @contents = [format_copyright, contents].join("\n\n")
      end
    end
  end
end
