require 'fileutils'

module Capistrano
  module ReliablyDeployingRails
    module Generators
      class BootstrapGenerator < Rails::Generators::Base
        source_root File.expand_path('../templates', __FILE__)
        desc "Bootstrap everything required to deploy with capistrano to a server configured with: https://github.com/TalkingQuickly/rails-server-template"

        def create_capfile
          template "Capfile.erb", 'Capfile'
        end

        def create_deployment_configuration
          FileUtils.mkdir_p 'config/deploy'
          template "deploy.rb.erb", 'config/deploy.rb'
          template "production.rb.erb", 'config/deploy/production.rb'
          template "staging.rb.erb", 'config/deploy/staging.rb'
        end

        def create_local_config_templates
          FileUtils.mkdir_p 'config/deploy/templates'
          base_path = File.expand_path('../templates', __FILE__)

          %w(
            nginx_conf.erb
            puma_monit.conf.erb
            puma.rb.erb
            puma.service.erb
            sidekiq_monit.erb
            sidekiq.service.capistrano.erb
          ).each do |file|
            unless File.file?(file)
              copy_file(File.join(base_path, file), "config/deploy/templates/#{file}")
            end
          end
        end

        private
      end
    end
  end
end