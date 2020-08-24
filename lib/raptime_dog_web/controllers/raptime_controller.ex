defmodule RaptimeDogWeb.RaptimeController do
  use RaptimeDogWeb, :controller

  def list(conn, _params) do
    # list = RaptimeDog.Scraper.RaceList.get()
    success(conn, %{hello: "world"})
  end

  def detail(conn, %{"url" => url}) do
    # success(conn, RaptimeDog.Scraper.RaceDetail.get(url))
    success(conn, %{hello: "world"})
  end
end
