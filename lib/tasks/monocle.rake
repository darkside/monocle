namespace :monocle do
  task :list => :environment do
    Monocle.list
  end

  task :versions => :environment do
    Monocle.versions
  end

  task :migrate => :environment do
    Monocle.migrate
    Rake::Task['db:structure:dump'].invoke
  end

  task :bump, [:view_name] do |t, args|
    Rake::Task['environment'].invoke
    view_name = args.view_name
    Monocle.bump(view_name)
  end
end
