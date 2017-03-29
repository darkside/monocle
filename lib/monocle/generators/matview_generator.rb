require "rails/generators"

module Monocle::Generators
  class MatviewGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    class_option :skip_model, type: :boolean, default: false, desc: "Skips model generation"

    def generate_sql_file
      create_file "db/views/#{file_name}.sql" do
        <<-EOF
        -- Timestamp: #{Time.now}
        CREATE MATERIALIZED VIEW #{file_name} AS
        -- Add your stuff here
        ;
        EOF
      end
    end

    def generate_model_file
      # Don't do anything if we're skipping this
      return if options[:skip_model]
      # Invoke rails' nifty model generator for us
      invoke "model", [file_path.singularize], options.merge(migration: false, test_framework: false)
    end

  end
end
