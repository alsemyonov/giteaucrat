# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2016, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'grit/blame'

module Grit
  class Blame
    def process_raw_blame(output)
      lines = []
      final = []
      info = {}
      commits = {}

      # process the output
      output.split("\n").each do |line|
        if line[0, 1] == "\t"
          lines << line[1, line.size]
        elsif m = /^(\w{40}) (\d+) (\d+)/.match(line)
          commit_id = m[1]
          old_lineno = m[2].to_i
          lineno = m[3].to_i
          commits[commit_id] = nil unless commits.key?(commit_id)
          info[lineno] = [commit_id, old_lineno]
        end
      end

      # load all commits in single call
      @repo.batch(*(commits.keys - ['0' * 40])).each do |commit|
        commits[commit.id] = commit if commit
      end

      # get it together
      info.sort.each do |lineno, (commit_id, old_lineno)|
        commit = commits[commit_id]
        final << BlameLine.new(lineno, old_lineno, commit, lines[lineno - 1])
      end

      @lines = final
    end
  end
end
