defmodule Sabotnik.ReactionGifs do

  use HTTPoison.Base

  def random_gif(tags) when is_list(tags) do
    :random.seed(:os.timestamp)
    response = get!(tag_list(tags))
    IO.inspect response
    response.body
    |> Enum.shuffle
    |> List.first
  end

  def process_url(tags) do
    "http://replygif.net/api/gifs?api-key=39YAprx5Yi&tag-operator=or&tag=#{tags}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn (gif) -> Dict.get(gif, "url") end)
  end

  def tag_list(tags), do: Enum.join(tags, ",")

end
