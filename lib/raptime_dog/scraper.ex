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
      html = get_basehtml(url)
      table = html |> Meeseeks.one(css(".ShutubaTable"))
      horses = table |> Meeseeks.all(css(".HorseList")) |> Enum.map(&parse_horse_detail/1)
      %{
        race_num: html |> Meeseeks.one(css(".RaceList_NameBox .RaceNum")) |> Meeseeks.text(),
        race_name: html |> Meeseeks.one(css(".RaceList_NameBox .RaceName")) |> Meeseeks.text() |> String.trim(),
        race_field: html |> Meeseeks.one(css(".RaceList_NameBox .RaceData01")) |> Meeseeks.text() |> String.trim(),
        race_detail: html |> Meeseeks.all(css(".RaceList_NameBox .RaceData02 span")) |> Enum.map(&Meeseeks.text/1),
        horses: horses
      }
    end

    defp parse_horse_detail(horse_html) do
      :timer.sleep(100)
      %{
        pos: horse_html |> Meeseeks.one(css(".Waku")) |> Meeseeks.text(),
        num: horse_html |> Meeseeks.one(css(".Umaban")) |> Meeseeks.text(),
        name: horse_html |> Meeseeks.one(css(".HorseName a")) |> Meeseeks.text(),
        odds: horse_html |> Meeseeks.one(css(".Popular span")) |> Meeseeks.text(),
        data: horse_html |> Meeseeks.one(css(".HorseName a")) |> Meeseeks.attr("href") |> RaptimeDog.Scraper.HorseDetail.get()
      }
    end

    defp get_basehtml(url) do
      HTTPoison.get!(url).body
      |> MbcsRs.decode!("EUC-JP") # NOTE: 詳細画面はなぜかEUCJP
    end
  end

  defmodule HorseDetail do
    import Meeseeks.CSS

    def get(url) do
      html = get_basehtml(url)
      table = html |> Meeseeks.one(css("table.db_h_race_results"))
      records = table |> Meeseeks.all(css("tbody tr")) |> Enum.map(&parse_record/1)
      %{
        name: html |> Meeseeks.one(css(".horse_title h1")) |> Meeseeks.text(),
        info: html |> Meeseeks.all(css(".horse_title p")) |> List.last() |> Meeseeks.text(),
        records: records
      }
    end

    defp parse_record(row) do
        cols = row |> Meeseeks.all(css("td"))
        %{
          date: cols |> Enum.at(0) |> Meeseeks.text(),
          race_name: cols |> Enum.at(4) |> Meeseeks.text(),
          race_rank: cols |> Enum.at(11) |> Meeseeks.text(),
          race_info: cols |> Enum.at(14) |> Meeseeks.text() |> parse_race_info(),
          time: cols |> Enum.at(17) |> Meeseeks.text() |> parse_race_time(),
        }
    end

    defp parse_race_info(text) do
      case text do
        "芝" <> length -> %{type: "芝", length: length |> String.to_integer()}
        "ダ" <> length -> %{type: "ダ", length: length |> String.to_integer()}
        length -> %{type: "-", length: length}
      end
    end

    defp parse_race_time(nil), do: 0
    defp parse_race_time(""), do: 0
    defp parse_race_time(text) do
      times = Regex.run(~r/(\d+):(\d+)\.(\d+)/, text)
      m = times |> Enum.at(1) |> String.to_integer()
      s = times |> Enum.at(2) |> String.to_integer()
      ms = times |> Enum.at(3) |> String.to_integer()
      m * 60 + s + ms * 0.1
    end

    defp get_basehtml(url) do
      HTTPoison.get!(url).body
      |> MbcsRs.decode!("EUC-JP") # NOTE: 詳細画面はなぜかEUCJP
    end
  end
end
