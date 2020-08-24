defmodule RaptimeDogWeb.RaptimeController do
  use RaptimeDogWeb, :controller

  def index(conn, _params) do
    list = RaptimeDog.Scraper.RaceList.get()
    success(conn, list)
  end
end
