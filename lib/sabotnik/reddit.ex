defmodule Sabotnik.Reddit do

  require Reddhl

  def random_link(subreddit) do
    :random.seed(:os.timestamp)
    IO.inspect subreddit
    Reddhl.pull(subreddit) |>
      link()
  end

  def link(nil), do: nil
  def link([]), do: nil
  def link(threads) do
    threads |>
      Enum.shuffle |>
      List.first |>
      get_in(["data", "url"])
  end

end
