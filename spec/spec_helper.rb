require "bundler/setup"
require 'dotenv/load'
require "monocle"
require "pry"

Dir[File.join(Monocle.root, 'spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.mock_with :mocha

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseUtils.setup
  end

  config.after(:suite) do
    DatabaseUtils.teardown
  end
end
