defmodule Sabotnik do
  use Slack

  require IEx
  require Logger
  
  def start_link do
    start_link(Application.get_env(:sabotnik, :bot_token), [])
  end

  def init(initial_state, _slack) do
    {:ok, %{}}
  end

  def handle_connect(slack, state) do
    IO.puts("Connected as #{slack.me.name}")
    {:ok, state}
  end

  def handle_message(msg = %{type: "message"}, slack, state) do
    try do
      do_message(msg, slack, state)
    rescue
      error ->
        IO.puts "ERROR! #{inspect error}"
    end
    {:ok, state}
  end

  def handle_message(_msg, _slack, state) do
    {:ok, state}
  end

  defp do_message(msg, slack, state) do
    IO.puts "Message:"
    IO.inspect msg
    case Map.get(slack.channels, msg.channel) do
      nil ->
        do_addressed_message(msg.text, msg.channel, slack)
      channel ->
        if String.starts_with?(msg.text, slack.me.name <> ":") do
          do_addressed_message(strip_username(msg.text), channel, slack)
        end
    end
  end

  def do_addressed_message(msg, channel, slack) do
    case strip_username(msg) do
      "ping" ->
        send_message("mew", channel, slack)
      "pet" ->
        send_message("purr", channel, slack)
      _ ->
        :ok
    end
  end

  def strip_username(str) do
    str |>
      String.split(":") |>
      List.last |>
      String.strip
  end
  
end
