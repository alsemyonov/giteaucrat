# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2016, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat/formatters/ruby_formatter'

module Giteaucrat
  module Formatters
    class CoffeeFormatter < RubyFormatter
      def encoding
        nil
      end

      def add_copyright!
        @contents = [format_copyright, contents].join("\n\n")
      end
    end
  end
end
