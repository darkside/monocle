<img align="left" src="https://lh3.googleusercontent.com/SoJ_7q3soZxT97yNmlBx8eFqs7iXH_azC1H9vXCsglXq5GaR6rXCtf9Xzq42fJTAg7gL=s107"></img>
# Monocle

Monocle helps you tame your database views by keeping the SQLs versioned neatly in your project and knowing when and how to migrate them if necessary.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monocle'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monocle
    
## Setup

If you're using Rails, there are generators for bootstrapping the gem:

    $ rails g monocle:install

It will generate a migration for creating the Monocle::Migration table. If you're not using Rails, you'll need to create the table yourself. Check https://github.com/darkside/monocle/blob/master/spec/support/database_utils.rb for an example on how to do it.

## Usage

The basic gist is you have a `db/views` in your project which contains all the view / materialized view SQL definitions. On top of those files there's a timestamp that you can control. Every time you change that timestamp, Monocle will try to migrate that view when calling `rake monocle:migrate`. You can automate this easily by hooking `monocle:migrate` to your deployment process.

Monocle knows about view dependencies and will drop and recreate dependants as necessary. So if you have a view A that references a view B and you need to upgrade view B, it will drop view A first, then drop and create view B, then create view A.

## Included Generators (for Rails)

### Generating a view

With Rails, you can use the generator:

    $ rails g monocle:view view_name
    
This will generate a monocle SQL template and a model. You can skip creating the model with `--skip-model`.

### Generating a materialized view

With Rails, you can use the generator:

    $ rails g monocle:matview view_name
    
This will generate a monocle materialized SQL template and a model. You can skip creating the model with `--skip-model`.

## Included Rake Tasks

### List all views

You can use `rake monocle:list` to see all the view names that are being managed by Monocle.

### List all migrated view slugs

You can use `rake monocle:versions` to see all the view slugs that have been migrated by Monocle.

### Migrate views

You can use `rake monocle:migrate` to migrate any views that have a new timestamp. I recommend you hook this to your deployment process i.e after you call `rake db:migrate`

### Bumping a view timestamp

With monocle, you decide when it's time to upgrade a view. So even if you have an updated view definition that you're working on, it won't actually change it unless the timestamp has changed. To bump a view timestamp, you can either do it yourself by changing the first line of the template or use the supplied rake task: 

    $ rake monocle:bump[my_view_name]
    
It will automatically bump that view's timestamp to the current time.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/darkside/monocle.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

