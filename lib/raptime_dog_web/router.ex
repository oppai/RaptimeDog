defmodule RaptimeDogWeb.Router do
  use RaptimeDogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/api", RaptimeDogWeb do
    pipe_through :api

    get "/list", RaptimeController, :list
    get "/detail", RaptimeController, :detail
  end
end
