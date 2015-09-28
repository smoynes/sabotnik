defmodule Sabotnik.Cats do

  use HTTPoison.Base

  def random_gif() do
    response = get!("http://thecatapi.com/api/images/get?format=src")
    IO.inspect response
    response.headers
    |> Enum.reduce(nil, fn (e, acc) ->
      case e do
        {"Location", url} -> url
        {_, _} -> acc
      end
    end)
  end

end
