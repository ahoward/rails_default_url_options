# (Rails) Default URL Options

Provide consistent application URLs across your entire codebase.
Primarily useful for mailers.

## Install

From the command line:

```bash
gem install rails_default_url_options
```

From your `Gemfile`:

```ruby
gem 'rails_default_url_options'
```

## Setup

This gem will automatically set up `DefaultUrlOptions` in a Rails
web process after the first request. If you'd like to configure it
manually, use an initializer.

```ruby
# File: config/initializers/default_url_options.rb
DefaultUrlOptions.configure (
  case Rails.env
    when 'production'
      {
        :host     => 'app.com',
        :port     => false,     # no ports allowed in this one!
        :protocol => 'https'
      }
    when 'staging'
      {
        :host     => 'staging.app.com',
        :port     => 8080,
        :protocol => 'http'
      }
    else
      {
        :host     => '0.0.0.0',
        :port     => 3000,
        :protocol => 'http'
      }
  end
)
```

## Tips

Want to call Rails URL helpers from the command line or anywhere in your
code? Use [rails_helper](https://github.com/ahoward/rails_helper)!
