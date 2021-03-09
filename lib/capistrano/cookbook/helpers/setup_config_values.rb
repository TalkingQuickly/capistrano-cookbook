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

      def local_config_files
        fetch(:local_config_files) || local_config_files_defaults
      end

      private

      def symlinks_defaults
        [
          {
            source: "log_rotation",
            link: "/etc/logrotate.d/{{full_app_name}}"
          },
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
        )
      end

      def local_config_files_defaults
        %w(
          nginx_conf.erb
          puma_monit.conf.erb
          puma.rb.erb
          puma.service.erb
        )
      end
    end
  end
end
