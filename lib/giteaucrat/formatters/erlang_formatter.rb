# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2016, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat/formatters/coffee_formatter'

module Giteaucrat
  module Formatters
    class ErlangFormatter < CoffeeFormatter
      COMMENT_PARTS = %w(% % %)
      COPYRIGHT_REGEXP = %r{(?<ruler>%+\n)(?<copyright>(%\s*[^\s/]+.*\s%\n)+)(%\s+%?\n(?<comment>(%\s*.*%?\n)+))?\k<ruler>\n+}
    end
  end
end
