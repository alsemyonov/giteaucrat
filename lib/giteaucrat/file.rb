# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2016, MIT License #
# Authors: Alexander Semyonov <al@semyonov.us> #
#          Sergey Ukustov <sergey@ukstv.me>    #
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
        commits = lines.map(&:commit).uniq.find_all do |commit|
          !repo.ignored_commit?(commit)
        end
        commits.inject(Set.new) do |authors, commit|
          author = Author.find_by_git_person(commit.author)
          authors << author unless author.ignored?
          authors
        end
      end
    end

    def owner
      @owner ||= begin
        Author.find_by_git_person(repo.git_repo.log(name).last.author)
      rescue NoMethodError
        Author.new(name: repo.git_repo.config['user.name'],
                   email: repo.git_repo.config['user.email'])
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
