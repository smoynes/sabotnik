defmodule Sabotnik.Tasks do

  require Slack

  def async(mod, fun, msg, slack) do
    Task.async(fn ->
      case apply(mod, fun, [msg.text]) do
        nil -> :ok
        response -> Slack.send_message(response, msg.channel, slack)
      end
    end)
  end
  
end
