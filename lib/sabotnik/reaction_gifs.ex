defmodule Sabotnik.ReactionGifs do

  use HTTPoison.Base

  def random_gif(tags) when is_list(tags) do
    :random.seed(:os.timestamp)
    response = get!(tag_list(tags))
    IO.inspect response
    response.body
    |> Enum.shuffle
    |> List.first
    |> make_image_url
  end

  def random_gif(msg) do
    tags = tl(String.split(msg))
    random_gif(tags)
  end
  
  def process_url(tags) do
    "http://replygif.net/api/gifs?api-key=39YAprx5Yi&tag-operator=or&tag=#{tags}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn (gif) -> Dict.get(gif, "url") end)
  end

  def make_image_url(nil), do: nil
  def make_image_url(url) do
    String.replace(url, ~r/(\d+)/, "i/\\1.gif")
  end
  
  defp tag_list(tags), do: Enum.join(tags, ",")

end
