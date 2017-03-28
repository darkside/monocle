module DatabaseUtils

  def self.establish_connection
    ActiveRecord::Base.establish_connection(
      :adapter  => "postgresql",
      :host     => "localhost",
      :database => ENV["MONOCLE_DB_NAME"],
      :username => ENV["MONOCLE_DB_USER"],
      :password => ENV["MONOCLE_DB_PASS"]
    )
  end

  def self.setup
    establish_connection
    sql = <<-EOSQL
      CREATE TABLE IF NOT EXISTS public.monocle_migrations
      (
        version character varying
      )
      WITH (
        OIDS=FALSE
      );
      CREATE UNIQUE INDEX IF NOT EXISTS index_monocle_migrations_on_version
      ON public.monocle_migrations
      USING btree
      (version COLLATE pg_catalog."default");
    EOSQL
    ActiveRecord::Base.connection.execute sql
  end

  def self.teardown
    ActiveRecord::Base.connection.close
  end
end
