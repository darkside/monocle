# An in-memory representation of the view
module Monocle
  class View
    attr_reader :name
    attr_accessor :dependants

    delegate :views_path, :list, :versions, :logger, to: Monocle
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
      get_dependants_from_pg.each(&:drop) # drop any existing dependants
      execute drop_command
      true
    end

    def create
      debug "Creating #{name}..."
      execute create_command
      Migration.find_or_create_by version: slug
      dependants.each &:create
      true
    rescue ActiveRecord::StatementInvalid => e
      # We may have another new view coming that this view depend on
      # if the relation name is included on our list of views, we create
      # that first and then retry
      if e.message =~ /PG::UndefinedTable/ &&
         e.message.scan(/relation \"(\w+)\" does not exist/) &&
         list.keys.include?($1.to_sym)
         warn "Can't create #{name} because it depends on #{$1}, creating that first..."
         list.fetch($1.to_sym).create
         retry
      else
        fail e
      end
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
      _concurrently = " CONCURRENTLY" if concurrently
      execute "REFRESH MATERIALIZED VIEW#{_concurrently} #{name}"
      true
    rescue ActiveRecord::StatementInvalid => e
      # This view is trying to select from a different view that hasn't been
      # populated.
      if e.message =~ /PG::ObjectNotInPrerequisiteState/ &&
         e.message.scan(/materialized view \"(\w+)\" has not been populated/) &&
         list.keys.include?($1.to_sym)
         warn "Can't refresh #{name} because it depends on #{$1} which hasn't been populated, refreshing that first..."
         list.fetch($1.to_sym).refresh
         retry
      else
        fail e
      end
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

    def exists?
      execute(check_if_view_exists_sql).entries.map(&:values).flatten.first
    end

    protected

    def check_if_view_exists_sql
      <<-SQL
        SELECT count(*) > 0
        FROM pg_catalog.pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relkind in ('m','v')
        AND n.nspname = 'public'
        AND c.relname = '#{name}';
      SQL
    end

    def get_dependants_from_pg
      map_dependants(execute(find_dependants_sql).entries.map(&:values).flatten - [name])
    end

    def map_dependants(deps)
      deps.map { |d| list[d.to_sym] }.compact
    end

    def find_dependants_sql
      <<-SQL
      WITH RECURSIVE vlist AS (
          SELECT c.oid::REGCLASS AS view_name
            FROM pg_class c
           WHERE c.relname = '#{name}'
           UNION ALL
          SELECT DISTINCT r.ev_class::REGCLASS AS view_name
            FROM pg_depend d
            JOIN pg_rewrite r ON (r.oid = d.objid)
            JOIN vlist ON (vlist.view_name = d.refobjid)
           WHERE d.refobjsubid != 0
      )
      SELECT * FROM vlist;
      SQL
    end

    def get_dependants_from_error(e)
      map_dependants e.message.scan(/(\w+) depends on.+view #{name}/).flatten
    end

    def execute(sql)
      ActiveRecord::Base.connection.execute(sql)
    end
  end

end
