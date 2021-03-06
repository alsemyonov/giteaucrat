# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2016, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat/formatters'
require 'delegate'

module Giteaucrat
  module Formatters
    class Formatter < SimpleDelegator
      HASHBANG_REGEXP = /\A(#!.*)\n/

      # @return [String]
      def format_copyright
        first, _, last = comment_parts
        lines = copyright_lines

        max_line_size = lines.max { |a, b| a.size <=> b.size }.size
        max_line_size += 1 if max_line_size.odd?

        lines = lines.map do |line|
          blank = ' ' * (max_line_size - line.size) if line.size < max_line_size
          "#{line}#{blank}"
        end

        line_width = first.size + 1 + max_line_size + 1 + last.size

        formatted = []
        formatted << header_ruler(line_width)
        formatted << lines.map { |line| format_line(line) }
        formatted << footer_ruler(line_width)
        formatted.join("\n")
      end

      def comment_parts
        self.class.const_get(:COMMENT_PARTS)
      end

      def header_ruler(line_width)
        ruler(line_width)
      end

      def footer_ruler(line_width)
        ruler(line_width)
      end

      def ruler(line_width)
        first, middle, last = comment_parts
        ruler_width = (line_width - first.size - last.size) / middle.size
        "#{first}#{middle * ruler_width}#{last}"
      end

      def format_line(line)
        "  #{line}  "
      end

      def remove_copyright!
        if contents =~ HASHBANG_REGEXP
          @hashbang = Regexp.last_match(1)
          contents.sub!(HASHBANG_REGEXP, '')
        end
        contents.sub!(self.class.const_get(:COPYRIGHT_REGEXP), '')
        parse_comment($LAST_MATCH_INFO[:comment]) if $LAST_MATCH_INFO && $LAST_MATCH_INFO[:comment]
      end

      def parse_comment(comment)
        @comment_lines = comment.split("\n")
        @copyright_lines = nil
      end

      attr_reader :comment_lines

      def comment?
        !!@comment_lines
      end

      # @return [String]
      def write_copyright!
        remove_copyright!
        add_copyright!
        @contents = [@hashbang, contents].compact.join("\n")
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

          if owner || authors.size > 0
            authors_label = (authors.size > 1) ? 'Authors: ' : 'Author: '
            author_names = (authors - [owner]).map(&:identifier).sort
            prepend = ' ' * authors_label.size
            lines << "#{authors_label}#{owner.identifier}"
            author_names.each do |author|
              lines << "#{prepend}#{author}"
            end
          end

          if comment?
            lines << ''
            lines += comment_lines
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
