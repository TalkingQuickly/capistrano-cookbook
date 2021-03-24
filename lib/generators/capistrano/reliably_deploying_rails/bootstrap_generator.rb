require 'fileutils'

module Capistrano
  module ReliablyDeployingRails
    module Generators
      class BootstrapGenerator < Rails::Generators::Base
        source_root File.expand_path('../templates', __FILE__)
        desc "Bootstrap everything required to deploy with capistrano to a server configured with: https://github.com/TalkingQuickly/rails-server-template"
        class_option :sidekiq, type: :boolean, default: false
        class_option :production_hostname, type: :string, default: nil
        class_option :production_server_address, type: :string, default: nil

        def setup
          @production_hostname = options[:production_hostname] || 'YOUR_PRODUCTION_HOSTNAME'
          @production_server_address = options[:production_server_address] || 'YOUR_PRODUCTION_SERVER_ADDRESS'
          @generate_sidekiq = options[:sidekiq]
        end

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

          templates(@generate_sidekiq).each do |file|
            unless File.file?(file)
              copy_file(File.join(base_path, file), "config/deploy/templates/#{file}")
            end
          end
        end

        private

        def templates(generate_sidekiq)
          return puma_templates unless generate_sidekiq
          puma_templates + sidekiq_templates
        end

        def puma_templates
          %w(
            nginx_conf.erb
            puma_monit.conf.erb
            puma.rb.erb
            puma.service.erb
            sidekiq_monit.erb
            sidekiq.service.capistrano.erb
          )
        end

        def sidekiq_templates
          %w(
            sidekiq_monit.erb
            sidekiq.service.capistrano.erb
          )
        end
      end
    end
  end
end