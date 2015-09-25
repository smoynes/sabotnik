defmodule Sabotnik do
  use Slack

  require Logger
  
  def start_link do
    start_link(Application.get_env(:sabotnik, :bot_token), [name: __MODULE__])
  end

  def stop(pid) do
    GenServer.stop(__MODULE__)
  end
  
  def init(initial_state, _slack) do
    {:ok, initial_state}
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
    if String.starts_with?(msg.text, slack.me.name <> ":") do
      case strip_username(msg.text) do
        "ping" ->
          send_message("mew", msg.channel, slack)
      end
    end
  end

  def strip_username(str) do
    str |>
      String.split(":") |>
      List.last |>
      String.strip
  end
  
end
