# coding: utf-8

################################################
# © Alexander Semyonov, 2013—2013, MIT License #
# Author: Alexander Semyonov <al@semyonov.us>  #
################################################

require 'giteaucrat'
require 'thor'
require 'yaml'

module Giteaucrat
  class Runner < Thor
    class_option :git, group: :git
    class_option :timeout, default: 30, group: :git
    class_option :path, default: Dir.pwd, desc: 'Path to project that needs some bureaucracy.'
    class_option :config,
                 default: ::File.join(Dir.pwd, 'config', 'giteaucrat.yml'),
                 desc: 'Giteaucrat configuration',
                 group: :giteaucrat
    class_option :commit_keyword,
                 aliases: %w(-i),
                 default: '#giteaucrat',
                 desc: 'Commit keyword to prepend giteaucrat commits (to ignore authorship of this commit)',
                 group: :giteaucrat
    class_option :copyright_owner,
                 aliases: %w(-o),
                 default: `git config user.name`.chomp,
                 desc: 'Company or owner name to put in copyright header',
                 group: :giteaucrat
    class_option :copyright_year,
                 aliases: %w(-y),
                 type: :numeric,
                 desc: 'Start year of copyright',
                 group: :giteaucrat
    class_option :copyright_format,
                 aliases: %w(-f),
                 default: '© %{owner}, %{years}',
                 desc: 'Start year of copyright',
                 group: :giteaucrat
    class_option :license,
                 aliases: %w(-l),
                 desc: 'License to put in copyright footer'
    class_option :include_encoding,
                 type: :boolean,
                 default: true,
                 aliases: %w(-e),
                 desc: 'Put encoding in copyright footer',
                 group: :giteaucrat
    class_option :commit,
                 type: :boolean,
                 aliases: %w(-c),
                 desc: 'Commit updated copyrights',
                 group: :giteaucrat
    class_option :patterns,
                 type: :array,
                 aliases: %w(-f),
                 desc: 'Files to copyright',
                 group: :giteaucrat

    desc 'copyrights', 'Update copyright information in files'

    def copyrights
      repo.write_copyrights!
      repo.commit!("#{defaults[:commit_keyword]}: Update copyrights in source code") if options[:commit]
      FileUtils.mkdir_p(::File.join(path, 'tmp'))
      ::File.write(::File.join(path, 'tmp', 'giteaucrat_authors.yml'), Author.to_yaml)
    end

    private

    def defaults
      @defaults ||= begin
        YAML::ENGINE.yamler = 'syck'
        Encoding.default_external = 'utf-8'
        Encoding.default_internal = 'utf-8'

        options = Thor::CoreExt::HashWithIndifferentAccess.new(self.options.dup)
        options[:config] = ::File.join(options[:path], 'config', 'giteaucrat.yml')

        if ::File.file?(options[:config])
          config = YAML.load_file(options[:config]) || {}
          options.merge!(config)
        end

        config = options.inject({}) do |config, (key, value)|
          config[key] = value unless %w(config git path timeout commit).include?(key); config
        end.to_yaml

        unless ::File.file?(options[:config])
          FileUtils.mkdir_p(::File.dirname(options[:config]))
          ::File.write(options[:config], config)
        end

        Dir.chdir(path)
        Repo.defaults = {git: options[:git], git_timeout: options[:timeout]}
        options
      end
    end

    def path
      options[:path]
    end

    # @return [Giteaucrat::Repo]
    def repo
      @repo ||= Repo.new(defaults)
    end
  end
end
