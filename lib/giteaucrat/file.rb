# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013              #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat'
require 'grit'
require 'core_ext/grit/blame'
require 'giteaucrat/formatters'

module Giteaucrat
  class File
    include Common

    # @return [String]
    attr_accessor :name

    # @return [Giteaucrat::Repo]
    attr_accessor :repo

    def authors
      @authors ||= begin
        blame = repo.git_repo.blame(name)
        lines = blame.lines
        commits = lines.map { |line| line.commit }.uniq.find_all do |commit|
          !repo.ignored_commit?(commit)
        end
        commits.inject(Set.new) do |authors, commit|
          author = Author.find_by_git_person(commit.author)
          authors << author unless author.ignored?
          authors
        end
      end
    end

    def read_contents
      ::File.read(name)
    end

    def write_contents(contents)
      ::File.write(name, contents)
    end

    def formatter
      @formatter ||= Formatters.formatter_for(self)
    end

    def write_copyright!
      formatter.write_copyright!
    end
  end
end
