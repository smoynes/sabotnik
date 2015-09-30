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

  def websocket_info(msg = {ref, _reply}, _, handler_state = %{state: state}) do
    case Task.find(state.tasks, msg) do
      {_, task} ->
        {:ok, %{handler_state | state: put_in(state[:tasks], List.delete(state.tasks, task))}}
      _ ->
        {:ok, handler_state}
    end
  end

  def websocket_info(msg, _, %{state: state}) do
    IO.puts "Received platform message:"
    IO.inspect msg
    {:ok, state}
  end

  def do_message(msg, slack, state) do
    IO.puts "Message:"
    IO.inspect msg
    case do_addressed_message(msg, slack) do
      {:reply, message} ->
        send_message(message, msg.channel, slack)
        state
      :pass ->
        case handle_command(msg, slack) do
          {:reply, response} ->
            send_message(response, msg.channel, slack)
            state
          {:task, task} ->
            tasks = [task] ++ state.tasks
            %{state|tasks: tasks}
          :pass ->
            IO.puts "Unmatched #{msg[:text]}"
            state
        end
    end
  end

  def handle_command(msg, slack) do
    cond do
      msg[:text] === nil ->
        :pass
      Regex.match?(~r/!reaction/, msg.text) ->
        task = Sabotnik.Tasks.async(Sabotnik.ReactionGifs, :random_gif, msg, slack)
        {:task, task}
      Regex.match?(~r/!cat/, msg.text) ->
        task = Sabotnik.Tasks.async(Sabotnik.Cats, :random_gif, msg, slack)
        {:task, task}
      Regex.match?(~r/!reddit/, msg.text) ->
        task = Sabotnik.Tasks.async(Sabotnik.Reddit, :random_link, msg, slack)
        {:task, task}
      true ->
        :pass
    end
  end

  def do_addressed_message(msg, slack) do
    case strip_username(msg[:text], slack.me.name) do
      "ping" ->
        {:reply, "mew"}
      "pet" ->
        {:reply, "purr"}
      ":weed:" ->
        {:reply, "fucking love catnip"}
      _ ->
        :pass
    end
  end

  def strip_username(nil, _), do: nil

  def strip_username(str, username) do
    String.replace(str, ~r/#{username}:/, "") |> String.strip
  end

end
