# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2016, MIT License #
# Authors: Alexander Semyonov <al@semyonov.us> #
#          Sergey Ukustov <sergey@ukstv.me>    #
################################################

require 'giteaucrat'
require 'grit'

module Giteaucrat
  class Repo
    include Common

    def self.defaults=(options = {})
      Grit::Git.git_binary = options[:git] if options[:git]
      Grit::Git.git_timeout = options[:git_timeout] if options[:git_timeout]
    end

    def git_repo
      @git_repo ||= find_git_repo(path)
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
      files.each(&:write_copyright!)
    end

    # @return [<String>]
    def patterns
      @patterns || %w(app/**/*.rb lib/**/*.rb script/**/*.rb spec/**/*.rb test/**/*.rb)
    end

    attr_writer :patterns

    attr_writer :patterns

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
      @copyright_label ||= copyright_format
                           .gsub('%{years}', [copyright_year, Time.now.year].compact.join('—'))
                           .gsub('%{owner}', copyright_owner)
                           .gsub('%{license}', license || '')
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

    private

    # Finds a Git repository in the +directory+ or its parent directories.
    # @param directory [String] Directory to expect a git repository.
    # @return [Grit::Repo] Found git repository.
    def find_git_repo(directory)
      if ::File.exist?(::File.join(directory, '.git')) || directory =~ /\.git$/
        Grit::Repo.new(directory)
      elsif directory == '/'
        fail Grit::InvalidGitRepositoryError
      else
        find_git_repo(::File.expand_path(::File.join(directory, '..')))
      end
    end
  end
end
