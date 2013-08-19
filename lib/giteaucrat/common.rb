# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013              #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat'

module Giteaucrat
  module Common
    def initialize(attributes = {})
      assign_attributes(attributes)
    end

    # @param [Hash] attributes
    def assign_attributes(attributes)
      attributes.each do |name, value|
        writer = "#{name}="
        value = value.force_encoding('utf-8') if value.respond_to?(:force_encoding)
        if respond_to?(writer)
          public_send(writer, value)
        else
          STDERR.puts("Unknown method #{self.class}##{writer}")
        end
      end
    end
  end
end
