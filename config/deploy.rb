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

  desc <<-DESC
  A macro-task that updates the code and fixes the symlink.
  DESC
  task :default do
    transaction do
      update_code
      create_symlink
      compile_harp
    end
  end

  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    strategy.deploy!
  end

  task :after_deploy do
    cleanup
  end

  task :compile_harp do
    run "harp compile #{deploy_to}/current"
    run "sudo rm -r #{deploy_to}/current/public/ #{deploy_to}/current/harp.json #{deploy_to}/current/readme.md"
    run "sudo mv #{deploy_to}/current/www/* #{deploy_to}/current/."
    run "sudo rm -r #{deploy_to}/current/www"
  end

end