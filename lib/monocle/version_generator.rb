module Monocle
  class VersionGenerator
    attr_reader :path, :view

    def initialize(path)
      @path = path
      @view = File.basename(path, ".sql")
    end

    def generate
      timestamp = File.open path, &:readline
      fail "can't read timestamp of #{path}! Aborting..." unless timestamp.starts_with? "-- Timestamp: "
      # Get only the digits out of the timestamp line
      timestamp.gsub!(/[^\d]/, '')
      "#{view}_#{timestamp}"
    end
  end
end
