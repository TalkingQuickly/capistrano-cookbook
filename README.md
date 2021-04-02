# Capistrano::Cookbook

A collection of Capistrano 3 Compatible tasks to make deploying Rails and Sinatra based applications easier.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-cookbook', require: false, group: :development

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-cookbook

## Versioning

This gem is primarily intended to provide a batteries included approach to getting Rails applications up and running. It is tested with the server configuration in <https://github.com/TalkingQuickly/rails-server-template>.

Major versions of the rails server template above and this gem stay in sync. So Version X.*.* of this gem should provide a working out of the box capistrano configuration when used with version X.*.* of the server template.

Major and minor versions of this gem, the server template and the book [Reliably Deploying Rails Applications](https://leanpub.com/deploying_rails_applications) also stay in sync. Updates to the book are free for life so on a new project, it's always advisable to make sure you have the latest version.

## Usage

### Boostrap

To generate a complete Capistrano configuration include the gem in your Gemfile and then use the following Rails Generator:

```
bundle exec rails g capistrano:reliably_deploying_rails:bootstrap --sidekiq --production_hostname='YOUR_PRODUCTION_DOMAIN' --production_server_address='YOUR_PRODUCTION_SERVER'
```

Replacing `YOUR_PRODUCTION_DOMAIN` with the domain name people will access the Rails app on and `YOUR_PRODUCTION_SERVER` with the address or ip that can be used to access the server via SSH, these may be the same thing but often will not be (e.g. if the domain has a CDN or Load Balancer between it and the server you're deploying to),

This will generate a complete Capistrano configuration.

You can then execute:

```
bundle exec cap production deploy:setup_config
bundle exec cap production database:create
```

To perform setup tasks and create a new empty database. Followed by:

```
bundle exec cap production deploy
```

To kick off you first deploy.

### Including Tasks Manually

To include all tasks from the gem, add the following to your `Capfile`:

```ruby
require 'capistrano/cookbook'
```

Otherwise you can include tasks individually:

```ruby
require 'capistrano/cookbook/check_revision'
require 'capistrano/cookbook/compile_assets_locally'
require 'capistrano/cookbook/create_database'
require 'capistrano/cookbook/logs'
require 'capistrano/cookbook/monit'
require 'capistrano/cookbook/nginx'
require 'capistrano/cookbook/run_tests'
require 'capistrano/cookbook/setup_config'
```

### The Tasks

#### Check Revision

Checks that the remote branch the selected stage deploys from, matches the current local version, if it doesn't the deploy will be halted with an error. 

Add the following to `deploy.rb`

```ruby
before :deploy, 'deploy:check_revision'
```

#### Compile Assets Locally

Compiles local assets and then rsyncs them to the production server. Avoids the need for a javascript runtime on the target machine and saves a significant amount of time when deploying to multiple web frontends.

Add the following to `deploy.rb`

``` ruby
 after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
 ```

#### Create Database

Currently only works with Postgresql on configurations where your web server and db server are the same machine, e.g. single box deployments. This task will:

* Check to see if a remote `database.yml` exists in `APP_PATH/shared/config`, if not attempt to copy one from `APP_PATH/shared/config`
* If a new `database.yml` is created, it will include a username and database name based on the application name and a random password
* Download the remote `database.yml`
* Create the Postgres user specified in `database.yml` if it doesn't already exist
* Create the Database specified in `database.yml` if it doesn't already exist
* Grant the user all permissions on that database

Run using:

``` bash
cap STAGE database:create
```

#### Logs

Allows remote log files (anything in `APP_PATH/shared/log`) to be tailed locally with Capistrano rather than SSHing in.

To tail the log file `APP_PATH/shared/log/production.log` on the `production` stage:

``` bash
cap production 'logs:tail[production]'
```

To tail the log file `APP_PATH/shared/log/unicorn.log`

``` bash
cap production 'logs:tail[unicorn]'
```

#### Monit

Provides convenience tasks for restarting the Monit service.

Available actions are `start`, `stop` and `restart`.

Usage:

```bash
cap STAGE monit:start
cap STAGE monit:stop
cap STAGE monit:restart
```

#### Nginx

Provides convenience tasks for interacting with Nginx using its `init.d` script as well as an additional task to remove the `default` virtualhost from `/etc/nginx/sites-enabled`

Available actions are `start`, `stop`, `restart`, `reload`, `remove_default_vhost`.

`reload` will reload the nginx virtualhosts without restarting the server.

Usage:

```bash
cap STAGE nginx:start
cap STAGE nginx:stop
cap STAGE nginx:restart
cap STAGE nginx:remove_default_vhost
```

#### Run Tests

Allows a test suite to be automatically run with `rspec`, if the tests pass the deploy will continue, if they fail, the deploy will halt and the test output will be displayed.

Usage:

Define the tests to be run in `deploy.rb`

``` ruby
set(:tests, ['spec'])
```

and add a hook in `deploy.rb` to run them automatically:

``` ruby
before "deploy", "deploy:run_tests"
```

#### Setup Config

The `deploy:setup_config` tasks provides a simple way to automate the generation of server specific configuration files and the setting up of any required symlinks outside of the applications normal directory structure.

If no values are provided in `deploy.rb` to override the defaults then this task includes opinionated defaults to setup a server for deployment as explained in the book [Reliably Deploying Rails Applications](https://leanpub.com/deploying_rails_applications) and [this tutorial](http://www.talkingquickly.co.uk/2014/01/deploying-rails-apps-to-a-vps-with-capistrano-v3/).

Each of the `config_files` will be created in `APP_PATH/shared/config`.

The task looks in the following locations for a template file with a corresponding name with a `.erb` extension:

* `config/deploy/STAGE/FILENAME.erb`
* `config/deploy/shared/FILENAME.erb`
* `templates/FILENAME.erb` directory of this gem ([github link](https://github.com/TalkingQuickly/capistrano-cookbook/tree/master/lib/capistrano/cookbook/templates))  

For any config files included in the `source` part of an entry in the `symlinks` array, a symlink will be created to the corresponding `link` location on the target machine.

Finally any config files included in `executable_config_files` will be marked as executable.

This task will also automatically invoke the following tasks:

* `nginx:remove_default_vhost`
* `nginx:reload`
* `monit:restart`

To ensure configuration file changes are picked up correctly.

The defaults are:

Config Files:

``` ruby
set(
  :config_files,
  %w(
  nginx.conf
  database.example.yml
  log_rotation
  monit
  unicorn.rb
  unicorn_init.sh
))
```

Symlinks:

```ruby
set(
  :symlinks,
  [
    {
      source: "nginx.conf",
      link: "/etc/nginx/sites-enabled/{{full_app_name}}"
    },
    {
      source: "unicorn_init.sh",
      link: "/etc/init.d/unicorn_{{full_app_name}}"
    },
    {
      source: "log_rotation",
     link: "/etc/logrotate.d/{{full_app_name}}"
    },
    {
      source: "monit",
      link: "/etc/monit/conf.d/{{full_app_name}}.conf"
    }
  ]
)
```

Executable Config Files:

```ruby
set(
  :executable_config_files,
  w(
    unicorn_init.sh
  )
)
```

## Contributing

1. Fork it ( http://github.com/talkingquickly/capistrano-cookbook/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
