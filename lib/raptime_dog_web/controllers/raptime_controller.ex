defmodule RaptimeDogWeb.RaptimeController do
  use RaptimeDogWeb, :controller

  def list(conn, _params) do
    list = RaptimeDog.Scraper.RaceList.get()
    success(conn, list)
  end

  def detail(conn, %{"url" => url}) do
    success(conn, RaptimeDog.Scraper.RaceDetail.get(url))
  end
end
