module Monocle
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(Monocle.root, "lib/tasks/monocle.rake")
    end

    generators do
      Dir[File.join(Monocle.root, "lib/monocle/generators/*.rb")].each { |f| require f }
    end

  end
end
