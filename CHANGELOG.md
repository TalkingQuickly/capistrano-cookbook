# Changelog

## 5.0.2 (April 2021)

- Adds support for automatically adding SSL certificates via Certbot

## 5.0.1 (March 2021)

- Adds full support for deploy (but not config creation) without sudo access
- Refactor config files to use single array of hashes with flags
- Refactor Sidekiq and Monit configurations to copy files directly rather than using symlinks to avoid potential root access leak
- Fixes bug where object identifier was outputted in logs rather than filename
- Fixes nginx not being reloaded after `setup_config` due to shared log directory not yet existing

## 5.0.0 (March 2021)

- Full overhaul to support Rails 6 and Ubuntu 20.04