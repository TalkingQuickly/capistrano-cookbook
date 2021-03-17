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
        [
          {
            source: "log_rotation",
            link: "/etc/logrotate.d/{{full_app_name}}"
          },
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
        %w(
          database.example.yml
          log_rotation
          secrets.yml
          sidekiq.service.capistrano
          sidekiq_monit
        )
      end
    end
  end
end
