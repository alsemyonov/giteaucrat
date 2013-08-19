require 'giteaucrat/formatters/formatter'

module Giteaucrat
  module Formatters
    class RubyFormatter < Formatter
      COMMENT_PARTS = %w(# # #)

      # @return [String]
      CODING_REGEXP = /\A(#\s*.*coding:\s*utf-8\s*\n+)?/
      COPYRIGHT_REGEXP = /(?<ruler>##+#\n)(?<copyright>(#\s*[\w\d]+.*\s#\n)+)(#\s+#?\n(?<comment>(#\s*.*#?\n)+))?\k<ruler>\n+/

      def format_copyright
        copyright = super
        copyright = "# coding: utf-8\n\n#{copyright}" if include_encoding?
        copyright
      end

      def format_line(line)
        "# #{line} #"
      end

      def remove_copyright!
        super
        contents.sub!(CODING_REGEXP, '') if include_encoding?
      end

      def add_copyright!
        if !include_encoding? && (contents =~ CODING_REGEXP)
          lines = contents.split(/\n/).to_a
          lines.insert(1, format_copyright)
          @contents = lines.join("\n")
        else
          super
        end
      end

      def parse_comment(comment)
        comment_lines = comment.split("\n").map do |line|
          line.sub(/\A#\s?/, '').sub(/\s*#\s*\Z/, '')
        end
        @comment_lines = comment_lines
      end

      def include_encoding?
        repo.include_encoding?
      end
    end
  end
end
