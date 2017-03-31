# Bare essentials from Rails to make this work neatly
require "active_support/core_ext/module/delegation"
require 'active_record'

require 'monocle/configuration'
require 'monocle/railtie' if defined?(Rails)

require "monocle/version"
require "monocle/version_generator"
require "monocle/view"
require "monocle/migration"

require "monocle/bump_command"
require "monocle/list_command"

module Monocle

  class << self
    delegate :path_to_views, :logger, to: :configuration

    def list
      @list ||= ListCommand.new.call
    end

    def drop(view_name)
      fetch(view_name).drop
    end

    def create(view_name)
      fetch(view_name).create
    end

    def versions
      Migration.versions
    end

    def migrate
      logger.info "Starting materialized views migrations..."
      list.each do |key, view|
        logger.debug "Checking if #{key} is up to date..."
        view.migrate
      end
      logger.info "All done!"
    end

    def bump(view_name)
      BumpCommand.new(fetch(view_name)).call
    end

    def refresh(view_name, concurrently: false)
      fetch(view_name).refresh concurrently: concurrently
    end

    # Enables you to configure things in a block, i.e
    # Monocle.configure do |config|
    #   config.logger = MyLogger.new
    #   config.path_to_views = "my/different/path/to/my/sql/files"
    # end
    def configure
      yield configuration if block_given?
    end

    def views_path
      File.join(root, path_to_views)
    end

    def root
      # Get the absolute path of the project who is using us
      File.expand_path(Dir.pwd)
    end

    def gem_root
      # Get the absolute path of our gem root
      File.expand_path(File.dirname(__dir__))
    end

    def fetch(view_name)
      view_name = symbolize_name(view_name)
      list.fetch(view_name)
    end

    protected

    def configuration
      @configuration ||= Configuration.new
    end


    def symbolize_name(name)
      name.is_a?(String) ? name.to_sym : name
    end
  end

end
