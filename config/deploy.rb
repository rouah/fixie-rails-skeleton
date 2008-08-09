set :application, "APPLICATION_NAME"
set :repository,  "YOUR_REPOSITORY_LOCATION"
set :scm, :git
set :ssh_options, { :forward_agent => true }
set :deploy_to, "/sites/#{application}"
set :user, 'joe'

set :use_sudo, false
role :app, "host"
role :web, "host"
role :db,  "host", :primary => true

namespace :deploy do
    # Used on solaris
    task :start, :roles => :app do
      invoke_command "/usr/sbin/svcadm enable groupy"
    end

    task :stop, :roles => :app do
      invoke_command "/usr/sbin/svcadm disable groupy"
    end

    task :restart, :roles => :app do
      invoke_command "/usr/sbin/svcadm restart groupy"
    end

    task :after_update_code, :roles => [:app] do
      run "ln -nfs #{release_path}/config/database.yml.live #{ release_path }/config/database.yml"
      run "ln -nfs #{release_path}/config/memcached.yml.live #{ release_path }/config/memcached.yml"
    end
end
