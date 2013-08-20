# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat'

module Giteaucrat
  module Formatters
    UnknownFormatError = Class.new(StandardError)

    EXTENSIONS = {
      '.rb' => :RubyFormatter,
      '.java' => :JavaFormatter,
      '.py' => :PythonFormatter,
      '.sass' => :SassFormatter,
      '.scss' => :SassFormatter,
      '.coffee' => :CoffeeFormatter,
    }

    module_function

    def formatter_for(file)
      extension = ::File.extname(file.name)
      formatter = EXTENSIONS[extension]
      raise(UnknownFormatError, extension) unless formatter
      const_get(formatter).new(file)
    end
  end
end

require 'giteaucrat/formatters/formatter'

require 'giteaucrat/formatters/coffee_formatter'
require 'giteaucrat/formatters/java_formatter'
require 'giteaucrat/formatters/python_formatter'
require 'giteaucrat/formatters/ruby_formatter'
require 'giteaucrat/formatters/sass_formatter'
