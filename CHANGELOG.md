# Changelog

## 5.0.1 (March 2021)

- Refactor config files to use single array of hashes with flags
- Refactor Sidekiq and Monit configurations to copy files directly rather than using symlinks to avoid potential root access leak
- Fixes bug where object identifier was outputted in logs rather than filename

## 5.0.0 (March 2021)

- Full overhaul to support Rails 6 and Ubuntu 20.04