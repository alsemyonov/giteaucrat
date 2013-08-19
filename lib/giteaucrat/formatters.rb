require 'giteaucrat'

module Giteaucrat
  module Formatters
    UnknownFormatError = Class.new(StandardError)

    EXTENSIONS = {
      '.rb' => :RubyFormatter,
      '.java' => :JavaFormatter,
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
require 'giteaucrat/formatters/ruby_formatter'
