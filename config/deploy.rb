set :application, "eau"
set :repository,  "ssh://pbelzile1@git.code.sf.net/p/gestioneaupourp/git"
set :deploy_to, "/var/www/eau"

set :scm, :git

role :web, "dixie"                          # Your HTTP server, Apache/etc
role :app, "dixie"                          # This may be the same as your `Web` server
role :db,  "dixie", :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

after "deploy:update_code", "deploy:checkout_subdir"

namespace :deploy do
    desc "Checkout subdirectory and delete all the other stuff"
    task :checkout_subdir do
        run "mv #{current_release}/#{application}/ /tmp && rm -rf #{current_release}/* && mv /tmp/#{application}/* #{current_release}"
    end
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
