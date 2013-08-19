# coding: utf-8

require 'giteaucrat'
require 'grit'
require 'core_ext/grit/blame'

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
          !ignored_commit?(commit)
        end
        commits.inject(Set.new) do |authors, commit|
          author = Author.find_by_git_person(commit.author)
          authors << author unless author.ignored?
          authors
        end
      end
    end

    def write_copyright!
      first, middle, last = comment
      first = Regexp.escape(first)
      middle = Regexp.escape(middle)
      last = Regexp.escape(last)
      contents = ::File.read(name)
      ruler = "(#{first}(#{middle})*#{last}\n)"
      coding = "(#{first}\s*.*coding:\s*utf-8\s*\n+)?"
      header = /#{coding}#{ruler}(#{first}.*#{last}\n)*\2\n*/m
      contents.sub!(header, '')
      ::File.write(name, "#{copyright}\n\n#{contents}")
    end

    def copyright
      @copyright ||= begin
        lines = []
        lines << repo.copyright_label

        if authors.size > 0
          authors_label = (authors.size > 1) ? 'Authors: ' : 'Author: '
          author_names = self.authors.map { |a| a.identifier }.sort
          prepend = ' ' * authors_label.size
          lines << "#{authors_label}#{author_names.shift}"
          author_names.each do |author|
            lines << "#{prepend}#{author}"
          end
        end

        first, middle, last = self.comment

        max_line_size = lines.max { |a, b| a.size <=> b.size }.size
        max_line_size += 1 if max_line_size.odd?

        width = first.size + 1 + max_line_size + 1 + last.size
        ruler = "#{first}#{middle * ((width / middle.size - first.size - last.size))}#{last}"
        lines = lines.map do |line|
          blank = ' ' * (max_line_size - line.size) if line.size < max_line_size
          "#{first} #{line}#{blank} #{last}"
        end

        lines.unshift(ruler)
        lines << ruler
        if repo.include_encoding?
          lines.unshift("#{first} coding: utf-8\n")
        end
        lines.join("\n")
      end
    end

    # @see Giteaucrat::Repo#ignored_commit?
    def ignored_commit?(commit)
      repo.ignored_commit?(commit)
    end

    # @return [<String, String, String>]
    def comment
      case ::File.extname(name)
      when '.rb', '.coffee', '.sass'
        %w(# # #)
      when '.js', '.css', '.scss'
        %w(/* * */)
      when '.erl'
        %w(% % %)
      else
        raise 'Unknown file type'
      end
    end
  end
end
