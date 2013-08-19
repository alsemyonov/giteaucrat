# coding: utf-8

require 'giteaucrat/formatters'
require 'delegate'

module Giteaucrat
  module Formatters
    class Formatter < SimpleDelegator
      # @return [String]
      def format_copyright
        first, middle, last = self.class.const_get(:COMMENT_PARTS)
        copyright_lines

        line_width = first.size + 1 + copyright_lines.first.size + 1 + last.size
        ruler_width = (line_width - first.size - last.size) / middle.size
        ruler = first + middle * ruler_width + last

        lines = []
        lines << ruler
        lines << copyright_lines.map { |line| "#{first} #{line} #{last}" }
        lines << ruler

        lines.join("\n")
      end

      # @return [String]
      def remove_copyright!
        STDERR.puts "Override #{self.class}#remove_copyright"
        contents
      end

      # @return [String]
      def write_copyright!
        remove_copyright!
        add_copyright!
        write_contents(contents)
      end

      def add_copyright!
        @contents = [format_copyright, contents].join("\n\n")
      end

      private

      def copyright_lines
        @copyright_lines ||= begin
          lines = []
          lines << repo.copyright_label
          if authors.size > 0
            authors_label = (authors.size > 1) ? 'Authors: ' : 'Author: '
            author_names = self.authors.map { |a| a.identifier }.sort
            prepend = ' ' * authors_label.size
            lines << "#{authors_label}#{author_names.shift}"
            author_names.each do |author|
              lines << "#{prepend}#{author}"
            end
          end

          max_line_size = lines.max { |a, b| a.size <=> b.size }.size
          max_line_size += 1 if max_line_size.odd?

          lines = lines.map do |line|
            blank = ' ' * (max_line_size - line.size) if line.size < max_line_size
            "#{line}#{blank}"
          end

          lines
        end
      end

      # @return [Giteaucrat::File]
      def file
        __getobj__
      end

      def contents
        @contents ||= read_contents
      end
    end
  end
end
