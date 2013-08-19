# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013              #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat'
require 'grit'

module Giteaucrat
  class Repo
    include Common

    def self.defaults=(options = {})
      if options[:git]
        Grit::Git.git_binary = options[:git]
      end
      if options[:git_timeout]
        Grit::Git.git_timeout = options[:git_timeout]
      end
    end

    def git_repo
      @git_repo ||= Grit::Repo.new(path)
    end

    # @return [String]
    attr_accessor :path
    attr_accessor :commit_keyword
    attr_writer :copyright_year
    attr_accessor :copyright_owner
    attr_accessor :copyright_format
    attr_accessor :license
    attr_accessor :include_encoding
    attr_writer :patterns

    def commit!(message)
      git_repo.commit_all(message)
    end

    def files
      @files ||= begin
        Dir.chdir(path) do
          patterns.inject([]) do |files, pattern|
            files + Dir[pattern]
          end.map do |file_name|
            File.new(name: file_name, repo: self)
          end
        end
      end
    end

    def write_copyrights!
      files.each do |file|
        file.write_copyright!
      end
    end

    # @return [<String>]
    def patterns
      @patterns || %w(app/**/*.rb lib/**/*.rb script/**/*.rb spec/**/*.rb test/**/*.rb)
    end

    attr_writer :patterns

    def patterns=(patterns)
      @patterns = patterns
    end

    def timeout
      Grit::Git.git_timeout
    end

    def timeout=(timeout)
      Grit::Git.git_timeout = timeout
    end

    def git
      Grit::Git.git_binary
    end

    def git=(executable)
      Grit::Git.git_binary = executable
    end

    def authors=(authors)
      authors.each do |author_attributes|
        Author.new(author_attributes)
      end
    end

    def config=(*)
    end

    # @return [Number]
    def copyright_year
      @copyright_year || first_commit.authored_date.year
    end

    # @return [Grit::Commit]
    def first_commit
      @first_commit ||= begin
        count = git_repo.commit_count
        git_repo.commits(git_repo.head.name, 1, count - 1).first
      end
    end

    # @return [String]
    def copyright_label
      @copyright_label ||= copyright_format.
        gsub('%{years}', [copyright_year, Time.now.year].compact.join('—')).
        gsub('%{owner}', copyright_owner).
        gsub('%{license}', license || '')
    end

    # @return [Regexp]
    def ignored_commit_message
      @ignored_commit_message ||= /^#{Regexp.escape(commit_keyword)}/
    end

    # @param [Grit::Commit] commit
    # @return [Boolean]
    def ignored_commit?(commit)
      !commit || commit.message.match(ignored_commit_message)
    end

    def include_encoding?
      !!include_encoding
    end
  end
end
