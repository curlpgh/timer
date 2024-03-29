import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :timer, TimerWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Timer.Finch

# Do not print debug messages in production
config :logger, level: :info

# DON'T LOG ERRORS TO A FILE IN PRODUCTION. MUST SETUP logrotate IN DOCKER IF YOU DO.
# tell logger to load LoggerFileBackend
config :logger, backends: [{LoggerFileBackend, :error_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "/var/lib/timer/error_logs/error.log",
  level: :info,
  format: "$date $time $metadata[$level] $message\n"

# password for timer user to be used when running this app on a local machine where
# authentication isn't required
config :timer,
  timer_user_email: "timer@timer.com",
  timer_user_password: "Timer123456789"

# bypass authentication if running locally and authentication is just in the way
config :timer, bypass_authentication: true

config :timer, :environment, :prod

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
