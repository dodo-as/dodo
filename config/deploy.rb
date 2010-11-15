set :application, "lodo"
set :use_sudo,    false

set :ssh_options, { :forward_agent => true }

set :scm, :git
set :git_shallow_clone, 1


desc "Deploying to production: cap dev deploy:migrations"
task :dev do
  set :repository,  "https://carlosforero@github.com/dodo-as/dodo.git"
  set :deploy_to, "/var/www/lodo_dev/"
  set :branch, "master"
  role :app, "dev.dodo.lodo.no"
  role :web, "dev.dodo.lodo.no"
  role :db,  "dev.dodo.lodo.no", :primary => true
  
end
	
desc "Deploying to staging server: cap staging deploy:migrations"
task :staging do
  set :deploy_to, "/var/www/lodo_staging/"
  role :app, "dev.dodo.lodo.no"
  role :web, "dev.dodo.lodo.no"
  role :db,  "dev.dodo.lodo.no", :primary => true
end

after("deploy:update_code") do
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
  run "ln -nfs #{deploy_to}/#{shared_dir}/log #{release_path}/log"
  run "/bin/chmod -R g+w #{release_path}"
end

namespace :deploy do
  desc "Restart application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

