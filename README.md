# Capistrano::Cookbook

A collection of Capistrano 3 Compatible tasks to make deploying Rails and Sinatra based applications easier.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-cookbook'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-cookbook

## Usage

### Including Tasks

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
require 'capistrano/cookbook/restart'
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

* Check to see if a remote `database.yml` exists in `APP_PATH/shared/config`, if not attempt to copy one from `APP_PATH/shared/config`.
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

#### Restart

Provides Commands for interacting with the Unicorn app server via an `init.d` script.

Usage:

``` bash
cap STAGE deploy:start
cap STAGE deploy:stop
cap STAGE deploy:force-stop
cap STAGE deploy:restart
cap STAGE deploy:upgrade
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

## Contributing

1. Fork it ( http://github.com/<my-github-username>/capistrano-cookbook/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
