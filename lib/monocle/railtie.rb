module Monocle
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(Monocle.root, "lib/tasks/monocle.rake")
    end
  end
end
