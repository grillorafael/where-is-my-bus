require 'yaml'
require './server'

def load_config
  config = YAML.load_file '../app_config.yml'
  config[config['env']]
end

config = load_config
server = Server.new config['server']['ip'], config['server']['port']
server.start