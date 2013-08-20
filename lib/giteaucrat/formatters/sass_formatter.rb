# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat/formatters/ruby_formatter'

module Giteaucrat
  module Formatters
    class SassFormatter < RubyFormatter
      COMMENT_PARTS = %w(// // //)
      COPYRIGHT_REGEXP = %r{(?<ruler>//+\n)(?<copyright>(//\s*[^\s/]+.*\s//\n)+)(//\s+//?\n(?<comment>(//\s*.*//?\n)+))?\k<ruler>\n+}

      def include_encoding?
        false
      end

      def add_copyright!
        @contents = [format_copyright, contents].join("\n\n")
      end
    end
  end
end
