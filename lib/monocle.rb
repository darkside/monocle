# Bare essentials from Rails to make this work neatly
require "active_support/core_ext/module/delegation"
require 'active_record'

require 'monocle/railtie' if defined?(Rails)

require "monocle/version"
require "monocle/version_generator"
require "monocle/view"
require "monocle/migration"

require "monocle/bump_command"
require "monocle/list_command"

module Monocle
  def self.list
    @list ||= ListCommand.new.call
  end

  def self.drop(view_name)
    fetch(view_name).drop
  end

  def self.create(view_name)
    fetch(view_name).create
  end

  def self.versions
    Migration.versions
  end

  def self.migrate
    logger.info "Starting materialized views migrations..."
    list.each do |key, view|
      logger.debug "Checking if #{key} is up to date..."
      view.migrate
    end
    logger.info "All done!"
  end

  def self.bump(view_name)
    BumpCommand.new(fetch(view_name)).call
  end

  def self.refresh(view_name, concurrently: false)
    fetch(view_name).refresh concurrently: concurrently
  end

  def self.logger
    # FIXME: This will need to be configurable
    @logger ||= if defined?(Rails)
      Rails.logger
    else
      Logger.new(STDOUT).tap do |logger|
        logger.level = Logger::ERROR
      end
    end
  end

  def self.views_path
    # FIXME: This will need to be configurable
    @views_path ||= if defined?(Rails)
      File.join Rails.root, "db/views"
    else
      File.join Monocle.root, "db/views"
    end
  end

  def self.root
    File.expand_path(File.dirname(__dir__))
  end

  protected

  def self.fetch(view_name)
    view_name = symbolize_name(view_name)
    list.fetch(view_name)
  end

  def self.symbolize_name(name)
    name.is_a?(String) ? name.to_sym : name
  end
end
