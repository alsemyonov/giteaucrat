# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013              #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat'
require 'set'

module Giteaucrat
  class Author
    include Common

    # @param [Grit::Actor] grit_author
    # @return [Author]
    def self.find_by_git_person(grit_author)
      name = grit_author.name.force_encoding('utf-8')
      email = grit_author.email.force_encoding('utf-8')
      author = all.find do |author|
        author.has_name?(name) || author.has_email?(email)
      end || new(name: name, email: email)
      author.names << name
      author.emails << email
      author
    end

    def self.all
      @all ||= Set.new
    end

    def self.new(attributes = {})
      author = super(attributes)
      all << author
      author
    end

    def self.check_multiple_emails!
      all.each do |_, author|
        author && author.check_multiple_emails!
      end
    end

    def self.to_yaml
      all.map do |author|
        author.to_hash
      end.sort { |a, b| a[:name] <=> b[:name] }.to_yaml
    end

    # @return [Boolean]
    attr_accessor :ignored

    # @return [Boolean]
    def ignored?
      !!@ignored
    end

    def check_multiple_emails!
      if emails.count > 1 && !instance_variable_defined?(:@email)
        STDERR.puts "#{name} has multiple emails:\n#{emails.map {|e| "* #{e}"}.join("\n")}\nPlease set right one in your giteaucrat.yml\n"
      end
    end

    # @return [Set<String>]
    def names
      @names ||= Set.new
    end

    # @param [<String>] names
    # @return [Set<String>]
    def names=(names)
      names.each { |name| self.names << name.force_encoding('utf-8') }
      self.names
    end

    # @return [String]
    def name
      @name || names.first
    end

    # @param [String] name
    def name=(name)
      name = name.force_encoding('utf-8')
      names << name
      @name = name
    end

    # @return [Boolean]
    # @param [String] name
    def has_name?(name)
      names.include?(name.force_encoding('utf-8'))
    end

    # @return [Set<String>]
    def emails
      @emails ||= Set.new
    end

    # @param [<String>] emails
    # @return [Set<String>]
    def emails=(emails)
      emails.each { |email| self.emails << email.force_encoding('utf-8') }
      self.emails
    end

    # @return [String]
    def email
      @email || emails.first
    end

    # @param [String] email
    # @return [String]
    def email=(email)
      email = email.force_encoding('utf-8')
      emails << email
      @email = email
    end

    # @return [Boolean]
    # @param [String] email
    def has_email?(email)
      emails.include?(email.force_encoding('utf-8'))
    end

    # @return [String]
    def identifier
      %(#{name} <#{email}>).force_encoding('utf-8')
    end

    # @return [Hash]
    def to_hash
      hash = {'name' => name.to_s, 'email' => email.to_s}
      hash['names'] = names.to_a - [name] if names.size > 1
      hash['emails'] = emails.to_a - [email] if emails.size > 1
      hash['ignored'] = true if ignored?
      hash
    end

    # @return [String]
    def to_s
      identifier
    end
  end
end
