module Monocle
  class Migration < ActiveRecord::Base
    self.table_name = 'monocle_migrations'
    def self.versions
      all.pluck(:version)
    end
  end
end
