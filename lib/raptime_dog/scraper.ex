defmodule RaptimeDog.Scraper do
  defmodule RaceList do
    import Meeseeks.CSS
    @base_url "https://race.netkeiba.com/top/race_list_sub.html?kaisai_date=20200830&current_group=1020200829"

    def get do
      parse_places_in_day()
      |> Enum.map(&parse_races_in_prace/1)
    end

    defp parse_races_in_prace(place_html) do
      place = place_html |> Meeseeks.one(css(".RaceList_DataHeader")) |> Meeseeks.text()
      races = place_html |> Meeseeks.all(css(".RaceList_DataItem")) |> Enum.map(&get_race_details/1)
      %{
      place: place,
      races: races
      }
    end

    defp get_race_details(race_html) do
      %{
          num: race_html |> Meeseeks.one(css(".Race_Num")) |> Meeseeks.text(),
          title: race_html |> Meeseeks.one(css(".ItemTitle")) |> Meeseeks.text(),
          starting_time: race_html |> Meeseeks.one(css(".RaceList_Itemtime")) |> Meeseeks.text(),
          num_of_horse: race_html |> Meeseeks.one(css(".RaceList_Itemnumber")) |> Meeseeks.text(),
          track_length: race_html |> Meeseeks.one(css(".RaceList_ItemLong")) |> Meeseeks.text(),
          href: race_html |> Meeseeks.one(css("a")) |> Meeseeks.attr("href") |> make_fullpath(),
      }
    end

    defp parse_places_in_day() do
      get_basehtml()
      |> Meeseeks.all(css("dl.RaceList_DataList"))
    end

    defp get_basehtml() do
      HTTPoison.get!(@base_url).body
    end

    defp make_fullpath(href) do
      "https://race.netkeiba.com/top/#{href}"
    end
  end

  defmodule RaceDetail do
    import Meeseeks.CSS

    def get(url) do
      table = get_basehtml(url) |> Meeseeks.one(css(".ShutubaTable"))
      table |> Meeseeks.all(css(".HorseList")) |> Enum.map(&parse_horse_detail/1)
    end

    defp parse_horse_detail(horse_html) do
      %{
        pos: horse_html |> Meeseeks.one(css(".Waku")) |> Meeseeks.text(),
        num: horse_html |> Meeseeks.one(css(".Umaban")) |> Meeseeks.text(),
        name: horse_html |> Meeseeks.one(css(".HorseName a")) |> Meeseeks.text(),
        odds: horse_html |> Meeseeks.one(css(".Popular span")) |> Meeseeks.text(),
        href: horse_html |> Meeseeks.one(css(".HorseName a")) |> Meeseeks.attr("href")
      }
    end

    defp get_basehtml(url) do
      HTTPoison.get!(url).body
      |> MbcsRs.decode!("EUC-JP") # NOTE: 詳細画面はなぜかEUCJP
    end
  end
end
