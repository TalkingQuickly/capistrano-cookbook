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
            source: "nginx.conf",
            link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
          },
          {
            source: "unicorn_init.sh",
            link: "/etc/init.d/unicorn_#{fetch(:full_app_name)}"
          },
          {
            source: "log_rotation",
           link: "/etc/logrotate.d/#{fetch(:full_app_name)}"
          },
          {
            source: "monit",
            link: "/etc/monit/conf.d/#{fetch(:full_app_name)}.conf"
          }
        ]
      end

      def executable_config_files_defaults
        %w(
          unicorn_init.sh
        )
      end

      def config_files_defaults
        %w(
          nginx.conf
          database.example.yml
          log_rotation
          monit
          unicorn.rb
          unicorn_init.sh
          secrets.yml
        )
      end
    end
  end
end
