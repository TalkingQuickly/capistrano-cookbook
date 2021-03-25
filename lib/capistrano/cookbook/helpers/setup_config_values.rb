module Capistrano
  module Cookbook
    class SetupConfigValues
      def config_files
        fetch(:config_files) || config_files_defaults
      end

      private

      def config_files_defaults
        base = [
          {
            source: 'log_rotation',
            destination: "/etc/logrotate.d/#{fetch(:full_app_name)}",
            executable: false,
            as_root: true 
          },
          {
            source: 'database.example.yml',
            destination: "#{shared_path}/config/database.example.yml",
            executable: false,
            as_root: false
          }
        ]

        return base unless sidekiq_enabled?

        base + [
          {
            source: 'sidekiq.service.capistrano',
            destination: "/home/#{fetch(:deploy_user)}/.config/systemd/user/#{fetch(:sidekiq_service_unit_name)}.service",
            executable: false,
            as_root: false
          },
          {
            source: "sidekiq_monit",
            destination: "/etc/monit/conf.d/#{fetch(:full_app_name)}_sidekiq.conf",
            executable: false,
            as_root: true
          }
        ]
      end

      def sidekiq_enabled?
        defined?(Capistrano::Sidekiq) == 'constant' && Capistrano::Sidekiq.class == Class
      end
    end
  end
end
