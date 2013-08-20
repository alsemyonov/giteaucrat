# coding: utf-8

require 'giteaucrat/formatters/ruby_formatter'

module Giteaucrat
  module Formatters
    class SassFormatter < RubyFormatter
      COMMENT_PARTS = %w(// // //)
      COPYRIGHT_REGEXP = %r{(?<ruler>//+\n)(?<copyright>(//\s*[\w\d]+.*\s//\n)+)(//\s+//?\n(?<comment>(//\s*.*//?\n)+))?\k<ruler>\n+}

      def include_encoding?
        false
      end

      def add_copyright!
        @contents = [format_copyright, contents].join("\n\n")
      end
    end
  end
end
