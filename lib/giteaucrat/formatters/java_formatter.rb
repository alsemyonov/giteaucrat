# coding: utf-8

require 'giteaucrat/formatters/formatter'

module Giteaucrat
  module Formatters
    class JavaFormatter < Formatter
      COMMENT_PARTS = %w(/* * */)

      COPYRIGHT_REGEXP = %r{/\*(?<ruler>\*+)\n(?<copyrights>(\s\*\s*[\w\d]+.*\n)+)(\s\*\s*\*?\n(?<comment>(\s\*\s?.*\*?\n)+))?(\s\g<ruler>\**/\n+)}

      def format_line(line)
        " * #{line} *"
      end

      def header_ruler(line_width)
        "/*#{'*' * (line_width - 3)}"
      end

      def footer_ruler(line_width)
        " #{'*' * (line_width - 3)}*/"
      end

      def parse_comment(comment)
        comment_lines = comment.split("\n").map do |line|
          line.sub(/\A\s\*\s?/, '').sub(/\s*\*\s*\Z/, '')
        end
        @comment_lines = comment_lines
      end
    end
  end
end
