require 'locomotive/steam'
require 'locomotive/steam/server'

Locomotive::Steam.configure do |config|
  config.asset_path = Rails.root.join('spec', 'dummy', 'public')

  # rely on Mongoid for the connection information
  if mongoid = Mongoid.configure.sessions[:default]
    config.adapter = { name: :'mongoDB', database: mongoid[:database], hosts: mongoid[:hosts] }
  end

  # if Steam is used inside the engine, we can rely on the Rails
  # middlewares for the session and the request.
  config.middleware.delete Rack::Lint
  config.middleware.delete Rack::Session::Moneta

  config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Middlewares::PageEditing

  # config.services_hook = -> (services) {
  #   Rails.logger.warn "TODO: change content entry submission"
  # }
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config_file = Rails.root.join('log', 'steam.log')
  config.notifier = Locomotive::Common::Logger.setup(config_file.to_s)
end
