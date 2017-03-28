module Monocle
  class Migration < ActiveRecord::Base
    def self.versions
      all.pluck(:version)
    end
  end
end
