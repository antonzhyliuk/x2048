defmodule X2048Web.GameChannel do
  use X2048Web, :channel
  alias X2048.Game

  intercept(["new_msg"])

  @impl true
  def join("game:" <> game_id, _payload, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :game_id, game_id)}
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{
      body: body,
      username: socket.assigns.username,
      id: Ecto.UUID.generate
    })
    {:noreply, socket}
  end

  def handle_in("turn", %{"direction" => direction}, socket) do
    game = Game.turn(socket.assigns.username, socket.assigns.game_id, direction)
    broadcast!(socket, "game_state", game)
    {:noreply, socket}
  end

  def handle_in("put_obstacle", _payload, socket) do
    game = Game.put_obstacle(socket.assigns.game_id)
    broadcast!(socket, "game_state", game)
    {:noreply, socket}
  end

  def handle_in("drop_obstacle", _payload, socket) do
    game = Game.drop_obstacle(socket.assigns.game_id)
    broadcast!(socket, "game_state", game)
    {:noreply, socket}
  end

  def handle_in("toggle_mode", _payload, socket) do
    game = Game.toggle_mode(socket.assigns.game_id)
    broadcast!(socket, "game_state", game)
    {:noreply, socket}
  end

  @impl true
  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    game =
      Game.add_player(socket.assigns.game_id, socket.assigns.username)

    broadcast!(socket, "game_state", game)
    {:noreply, socket}
  end

  @impl true
  def terminate({:shutdown, _}, socket) do
    Game.drop_player(socket.assigns.game_id, socket.assigns.username)
    {:ok, socket}
  end

  def terminate(_, socket) do
    {:ok, socket}
  end
end
