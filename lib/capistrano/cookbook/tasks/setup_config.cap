require 'capistrano/dsl'
require 'capistrano/cookbook/helpers/setup_config_values'
require 'capistrano/cookbook/helpers/substitute_strings'
require 'capistrano/cookbook/helpers/template'
require 'capistrano/cookbook/nginx'
require 'capistrano/cookbook/monit'
require 'securerandom'

namespace :deploy do
  task :setup_config do
    conf = ::Capistrano::Cookbook::SetupConfigValues.new
    on roles(:app) do
      # make the config dir
      execute :mkdir, "-p #{shared_path}/config"

      # config files to be uploaded to shared/config, see the
      # definition of smart_template for details of operation.
      conf.config_files.each do |file|
        smart_template file
      end

      # which of the above files should be marked as executable
      conf.executable_config_files.each do |file|
        execute :chmod, "+x #{shared_path}/config/#{file}"
      end

      # symlink stuff which should be... symlinked
      conf.symlinks.each do |symlink|
        sudo "ln -nfs #{shared_path}/config/#{symlink[:source]} #{sub_strings(symlink[:link])}"
      end
    end
  end
end

# remove the default nginx configuration as it will tend
# to conflict with our configs.
before 'deploy:setup_config', 'nginx:remove_default_vhost'

# reload nginx to it will pick up any modified vhosts from
# setup_config
after 'deploy:setup_config', 'nginx:reload'

# Restart monit so it will pick up any monit configurations
# we've added
after 'deploy:setup_config', 'monit:reload'
