require 'giteaucrat/formatters/formatter'

module Giteaucrat
  module Formatters
    class RubyFormatter < Formatter
      COMMENT_PARTS = %w(# # #)

      # @return [String]
      CODING_REGEXP = /\A(#\s*.*coding:\s*utf-8\s*\n+)?/
      COPYRIGHT_REGEXP = /(##+#\n)(#\s.*\s#\n)+\1\n+/

      def format_copyright
        copyright = super
        copyright = "# coding: utf-8\n\n#{copyright}" if repo.include_encoding?
        copyright
      end

      def remove_copyright!
        contents.sub!(COPYRIGHT_REGEXP, '')
        contents.sub!(CODING_REGEXP, '') if repo.include_encoding?
      end

      def add_copyright!
        if !repo.include_encoding? && (contents =~ CODING_REGEXP)
          lines = contents.split(/\n/).to_a
          lines.insert(1, copyright)
          @contents = lines.join("\n")
        else
          super
        end
      end
    end
  end
end
