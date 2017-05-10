namespace :monocle do
  desc "List all Monocle managed views"
  task :list => :environment do
    Monocle.list
  end

  desc "List all Monocle view slugs"
  task :versions => :environment do
    Monocle.versions
  end

  desc "Migrate any monocle views that need migratin'"
  task :migrate => :environment do
    Monocle.migrate
    Rake::Task['db:structure:dump'].invoke
  end

  desc "Refreshes a given monocle view"
  task :refresh, [:view_name] => :environment do |t, args|
    Monocle.refresh(args.view_name)
  end

  desc "Refreshes a given monocle view"
  task :refresh_all => :environment do |t, args|
    Monocle.refresh_all
  end

  desc "Bump a monocle view's timestamp by name"
  task :bump, [:view_name] do |t, args|
    Rake::Task['environment'].invoke
    view_name = args.view_name
    Monocle.bump(view_name)
  end
end
