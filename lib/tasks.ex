defmodule Sabotnik.Tasks do

  import Slack, only: [send_message: 3]

  def async(mod, fun, msg, slack) do
    Task.async(fn ->
      case apply(mod, fun, [msg.text]) do
        nil -> :ok
        response -> send_message(response, msg.channel, slack)
      end
    end)
  end
  
end
