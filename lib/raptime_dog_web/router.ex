defmodule RaptimeDogWeb.Router do
  use RaptimeDogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/", RaptimeDogWeb do
    pipe_through :api

    get "/recently", RaptimeController, :index
  end
end
