# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat/version'

module Giteaucrat
  autoload :Author, 'giteaucrat/author'
  autoload :Common, 'giteaucrat/common'
  autoload :File, 'giteaucrat/file'
  autoload :Formatters, 'giteaucrat/formatters'
  autoload :Repo, 'giteaucrat/repo'
  autoload :Runner, 'giteaucrat/runner'
end
