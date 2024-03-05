defmodule TimerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :timer

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_timer_key",
    signing_salt: "GWq0OEvx",
    same_site: "Lax",
    encryption_salt: "kPbLyfZL",
    same_site: "Lax",
    # Expire in 7 days
    max_age: 60 * 60 * 24 * 7
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :timer,
    gzip: false,
    only: TimerWeb.static_paths()

  # File upload location
  case Application.compile_env(:timer, :environment) do
    :prod ->
      # must set validate_compile_env: false in release in mix.exs to avoid compile warning
      plug(Plug.Static,
        at: "/uploads",
        from: Application.compile_env(:timer, :uploads_directory),
        gzip: false
      )

    _ ->
      plug(Plug.Static, at: "/uploads", from: Path.expand('./uploads'), gzip: false)
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :timer
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug TimerWeb.Router
end
