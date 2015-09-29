defmodule Sabotnik.Tasks do

  import Slack, only: [send_message: 3]

  def async(mod, fun, msg, slack) do
    Task.async(fn ->
      response = apply(mod, fun, [msg.text])
      send_message(response, msg.channel, slack)
      :ok
    end)
  end
  
end
