# An in-memory representation of the view
module Monocle
  class View
    attr_reader :name
    attr_accessor :dependants

    delegate :views_path, :list, :versions, :logger, to: Monocle
    delegate :execute, to: ActiveRecord::Base.connection
    delegate :info, :warn, :error, :debug, to: :logger

    def initialize(name)
      @name = name
      @dependants = []
    end

    def materialized?
      !!(@materialized ||= create_command =~ /MATERIALIZED VIEW/i)
    end

    def drop
      debug "Dropping #{name}..."
      execute drop_command
      true
    rescue ActiveRecord::StatementInvalid => e
      # We have dependants, can't drop this directly.
      if e.message =~ /PG::DependentObjectsStillExist/
        # Find the views in the main list, drop them
        self.dependants = get_dependants_from_error e
        debug "Can't drop #{name}, it has dependants: #{dependants.map(&:name).join(', ')}"
        dependants.each &:drop
        # And try this again
        retry
      else
        fail e
      end
    end

    def create
      debug "Creating #{name}..."
      execute create_command
      Migration.find_or_create_by version: slug
      dependants.each &:create
      true
    end

    def migrate
      if versions.include?(slug)
        debug "Skipping #{name} as it's already up to date."
        true
      else
        status = drop && create
        info "#{name} migrated to #{slug}!"
        status
      end
    end

    def refresh(concurrently: false)
      # We don't refresh normal views
      return false unless materialized?
      _concurrently = "CONCURRENTLY" if concurrently
      execute "REFRESH MATERIALIZED VIEW #{_concurrently} #{name}"
    end

    def slug
      @slug ||= VersionGenerator.new(path_for_sql).generate
    end

    def drop_command
      _materialized = 'MATERIALIZED' if materialized?
      "DROP #{_materialized} VIEW IF EXISTS #{name};"
    end

    def create_command
      @create_command ||= File.read(path_for_sql)
    end

    def path_for_sql
      @path_for_sql ||= File.join views_path, "#{name}.sql"
    end

    protected

    def get_dependants_from_error(e)
      e.message.scan(/(\w+) depends on.+view #{name}/).
      flatten.map { |s| list.fetch s.to_sym }
    end

  end

end
