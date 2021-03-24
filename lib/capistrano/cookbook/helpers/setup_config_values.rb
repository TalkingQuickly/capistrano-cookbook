module Capistrano
  module Cookbook
    class SetupConfigValues
      def symlinks
        fetch(:symlinks) || symlinks_defaults
      end

      def executable_config_files
        fetch(:executable_config_files) || executable_config_files_defaults
      end

      def config_files
        fetch(:config_files) || config_files_defaults
      end

      private

      def symlinks_defaults
        base = [
          {
            source: "log_rotation",
            link: "/etc/logrotate.d/{{full_app_name}}"
          }
        ]
        return base unless sidekiq_enabled?

        base + [
          {
            source: "sidekiq.service.capistrano",
            link: "/etc/systemd/system/#{fetch(:sidekiq_service_unit_name)}.service"
          },
          {
            source: "sidekiq_monit",
            link: "/etc/monit/conf.d/#{fetch(:full_app_name)}_sidekiq.conf"
          }
        ]
      end

      def executable_config_files_defaults
        %w(
        )
      end

      def config_files_defaults
        base = %w(
          database.example.yml
          log_rotation
        )
        return base unless sidekiq_enabled?

        base + %w(
          sidekiq.service.capistrano
          sidekiq_monit
        )
      end

      def sidekiq_enabled?
        defined?(Capistrano::Sidekiq) == 'constant' && Capistrano::Sidekiq.class == Class
      end
    end
  end
end
