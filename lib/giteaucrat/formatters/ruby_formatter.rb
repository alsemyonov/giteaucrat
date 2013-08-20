# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat/formatters/formatter'

module Giteaucrat
  module Formatters
    class RubyFormatter < Formatter
      COMMENT_PARTS = %w(# # #)

      # @return [String]
      CODING_REGEXP = /\A((#\s*.*coding:\s*[^\s]+)\s*\n+)?/
      COPYRIGHT_REGEXP = /(?<ruler>##+#\n)(?<copyright>(#\s*[^\s#]+.*\s#\n)+)(#\s+#?\n(?<comment>(#\s*.*#?\n)+))?\k<ruler>\n+/

      def format_copyright
        copyright = super
        copyright = [encoding, copyright].compact.join("\n\n")
        copyright
      end

      def format_line(line)
        first, _, last = comment_parts
        "#{first} #{line} #{last}"
      end

      def remove_copyright!
        super
        contents.sub!(CODING_REGEXP, '')
        @encoding = $2 if $2
      end

      def parse_comment(comment)
        middle = Regexp.escape(comment_parts[1])
        comment_lines = comment.split("\n").map do |line|
          line.sub(/\A#{middle}\s?/, '').sub(/\s*#{middle}\s*\Z/, '')
        end
        @comment_lines = comment_lines
      end

      def include_encoding?
        repo.include_encoding?
      end

      def encoding
        @encoding || (include_encoding? && '# coding: utf-8' || nil)
      end
    end
  end
end
