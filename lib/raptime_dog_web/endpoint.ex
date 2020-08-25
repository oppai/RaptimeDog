defmodule RaptimeDogWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :raptime_dog

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_raptime_dog_key",
    signing_salt: "OBN2Cb9F"
  ]

  # socket "/socket", RaptimeDogWeb.UserSocket,
  #   websocket: true,
  #   longpoll: false

  def redirect_index(conn = %Plug.Conn{path_info: []}, _opts) do
    %Plug.Conn{conn | path_info: ["index.html"]}
  end
  def redirect_index(conn, _opts), do: conn
  plug :redirect_index

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :raptime_dog,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt index.html)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug RaptimeDogWeb.Router
end
