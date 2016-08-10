module Sinatra
  module AppConfig

    def self.registered(app)
      config = YAML.load(File.read("#{app.settings.root}/config/application.yml"))
      app.set :app_config, config[app.environment.to_s]
    end

  end

  register AppConfig
end