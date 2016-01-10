# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'giteaucrat/version'

Gem::Specification.new do |spec|
  spec.name = 'giteaucrat'
  spec.version = Giteaucrat::VERSION
  spec.authors = ['Alexander Semyonov']
  spec.email = %w(al@semyonov.us)
  spec.description = 'Automatically update copyright messages using git'
  spec.summary = 'The Git bureaucrat'
  spec.homepage = 'http://github.com/alsemyonov/giteaucrat'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'thor'
  spec.add_dependency 'grit'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
