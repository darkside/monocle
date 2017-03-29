require 'rails/generators'

module Monocle::Generators
  class InstallGenerator < Rails::Generators::Base
    def create_migration
      invoke "migration", ["CreateMonocleMigrations", "version:string:uniq", "--primary-key-type=false"], options
    end
  end
end
