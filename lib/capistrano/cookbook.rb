require "capistrano/cookbook/version"

module Capistrano
  module Cookbook
    require 'capistrano/cookbook/certbot'
    require 'capistrano/cookbook/check_revision'
    require 'capistrano/cookbook/create_database'
    require 'capistrano/cookbook/logs'
    require 'capistrano/cookbook/monit'
    require 'capistrano/cookbook/nginx'
    require 'capistrano/cookbook/puma_systemd'
    require 'capistrano/cookbook/run_tests'
    require 'capistrano/cookbook/setup_config'
    require 'capistrano/cookbook/sidekiq_systemd'
  end
end
