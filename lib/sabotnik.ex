defmodule Sabotnik do
  use Slack

  require IEx
  require Logger

  def start_link do
    start_link(Application.get_env(:sabotnik, :bot_token), %{tasks: []})
  end

  def init(_, _) do
    {:ok, %{tasks: []}}
  end

  def handle_connect(slack, state) do
    IO.puts("Connected as #{slack.me.name}")
    {:ok, state}
  end

  def handle_message(msg = %{type: "message"}, slack, state) do
    try do
      state = do_message(msg, slack, state)
      {:ok, state}
    rescue
      error ->
        IO.puts "ERROR! #{inspect error}"
      {:ok, state}
    end
  end

  def handle_message(_msg, _slack, state) do
    {:ok, state}
  end

  def websocket_info(msg, _, handler_state = %{state: state}) do
    case Task.find(state.tasks, msg) do
      {:ok, task} ->
        {:ok, %{handler_state | state: remove_task(state, task)}}
      _ ->
        {:ok, handler_state}
    end
  end

  def do_message(msg, slack, state) do
    IO.puts "Message:"
    IO.inspect msg
    case handle_command(msg, slack) do
      {:reply, response} ->
        send_message(response, msg.channel, slack)
        state
      {:task, task} ->
        %{state|tasks: Enum.into([task], state.tasks)}
      :ok ->
        IO.puts "Unmatched #{msg[:text]}"
        state
    end
  end

  @modules [
      Sabotnik.Reddit,
      Sabotnik.ReactionGifs,
      Sabotnik.Cats
  ]
  
  def handle_command(msg, slack) do
    text = strip_username(msg[:text], slack.me.name)
    cond do
      text == "ping"   -> {:reply, "mew"}
      text == "pet"    -> {:reply, "purr"}
      text == ":weed:" -> {:reply, "fucking love catnip"}
      mod = find_command_module(@modules, msg[:text]) ->
        start_command_task(mod, msg, slack)
      true ->
        :ok
    end
  end

  def find_command_module(_mods, nil), do: nil
  
  def find_command_module(mods, text) do
    Enum.find(mods, fn e ->
      Regex.match?(e.pattern, text)
    end)
  end

  def start_command_task(nil, _, _) do
    :ok
  end
  
  def start_command_task(mod, msg, slack) do
    try do
      task = Sabotnik.Tasks.async(mod, :respond, msg, slack)
      {:task, task}
    catch
      :timeout -> {:error, :timeout}
    end
  end

  def remove_task(state, task) do
    Map.update(state, :tasks, [], &List.delete(&1, task))
  end

  def strip_username(nil, _), do: nil

  def strip_username(str, username) do
    String.replace(str, ~r/#{username}:/, "") |> String.strip
  end

end
