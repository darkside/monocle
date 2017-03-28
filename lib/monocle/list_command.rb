module Monocle
  class ListCommand
    delegate :views_path, to: Monocle

    attr_reader :view_names

    def initialize
      @view_names = Dir[File.join(views_path, "*.sql")].map { |f| File.basename(f, ".sql") }
    end

    def call
      {}.tap do |hash|
        view_names.each do |view_name|
          hash[view_name.to_sym] = View.new(view_name)
        end
      end
    end
  end
end
