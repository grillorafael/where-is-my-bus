# replace these with your server's information
set :domain,  "rgrillo.com"
set :user,    "ubuntu"

# name this the same thing as the directory on your server
set :application, "where-is-my-bus"

# use your local repository as the source
set :repository, "file://#{File.expand_path('.')}"

# or use a hosted repository
#set :repository, "ssh://user@example.com/~/git/test.git"

server "#{domain}", :app, :web, :db, :primary => true

set :deploy_via, :copy
set :copy_exclude, [".git", ".DS_Store"]
set :scm, :git
set :branch, "master"
# set this path to be correct on yoru server
set :deploy_to, "/var/www/experiments/#{application}"
set :use_sudo, true
set :keep_releases, 2
set :git_shallow_clone, 1

default_run_options[:pty] = true
ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
ssh_options[:keys] = ["~/Downloads/myhosts.pem"]

# this tells capistrano what to do when you deploy
namespace :deploy do

  desc 'A macro-task that updates the code and fixes the symlink.'
  task :default do
    transaction do
      update_code
      create_symlink

      # dependencies
      compile_harp
      # change_env
      # restart_server
    end
  end

  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    strategy.deploy!
  end

  task :after_deploy do
    cleanup
  end

  task :dependencies do
    # run "bundle install"
    # run "npm install"
  end

  task :compile_harp do
    run "harp compile #{deploy_to}/current"
    run "sudo rm -r #{deploy_to}/current/public/ #{deploy_to}/current/harp.json #{deploy_to}/current/readme.md #{deploy_to}/current/Capfile #{deploy_to}/current/Gemfile #{deploy_to}/current/Gemfile.lock #{deploy_to}/current/package.json "
    run "sudo mv #{deploy_to}/current/www/* #{deploy_to}/current/."
    run "sudo rm -r #{deploy_to}/current/www"
  end

  task :change_env do
    path = "#{deploy_to}/current/app_config.yml"
    data = YAML.load_file path
    data["env"] = "production"

    File.open(path, 'w') do |f|
      YAML.dump(data, f)
    end
  end

  task :restart_server do
    run "sudo wheres_my stop"
    run "sudo ln -s #{deploy_to}/current/server/wheres_my.conf /etc/init/wheres_my.conf"
    run "sudo wheres_my start"
  end

end