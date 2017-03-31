module Monocle
  class Configuration
    attr_accessor :views_path, :logger

    # Define a custom logger
    def logger
      @logger ||= (defined?(Rails) ? Rails.logger : Logger.new(STDOUT))
    end

    # The relative path to where views are stored, relative to the root of the
    # project
    def path_to_views
      @views_path ||= "db/views"
    end
  end
end
