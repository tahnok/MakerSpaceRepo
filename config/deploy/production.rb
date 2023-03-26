# frozen_string_literal: true

role :app, %w[deploy@prod-server.makerepo.com]
role :web, %w[deploy@prod-server.makerepo.com]
role :db, %w[deploy@prod-server.makerepo.com]

set :branch, "master"
set :deploy_to, "/var/www/makerrepo"
set :keep_releases, 3
set :rbenv_ruby, "3.1.2"
set :maintenance_template_path,
    File.expand_path("../../maintenance/maintenance.html.erb", __FILE__)
