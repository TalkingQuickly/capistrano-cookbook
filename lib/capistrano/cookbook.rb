require "capistrano/cookbook/version"

module Capistrano
  module Cookbook
    require 'capistrano/cookbook/check_revision'
    require 'capistrano/cookbook/compile_assets_locally'
    require 'capistrano/cookbook/logs'
    require 'capistrano/cookbook/monit'
    require 'capistrano/cookbook/nginx'
    require 'capistrano/cookbook/restart'
    require 'capistrano/cookbook/run_tests'
    require 'capistrano/cookbook/setup_config'
  end
end
