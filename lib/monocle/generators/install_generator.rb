require 'rails/generators'

module Monocle::Generators
  class InstallGenerator < Rails::Generators::Base
    desc "Creates everything you need to start rolling with monocle"
    def create_migration
      invoke "migration", ["CreateMonocleMigrations", "version:string:uniq", "--primary-key-type=false"], options
    end
  end
end
