module Monocle
  class Configuration
    attr_accessor :path_to_views, :logger

    # Define a custom logger
    def logger
      @logger ||= (defined?(Rails) ? Rails.logger : Logger.new(STDOUT))
    end

    # The relative path to where views are stored, relative to the root of the
    # project
    def path_to_views
      @path_to_views ||= "db/views"
    end
  end
end
