defmodule X2048Web.GameChannel do
  use X2048Web, :channel
  alias X2048Web.Presence

  intercept(["new_msg"])

  @impl true
  def join("game:" <> _game_id, _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
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

  @impl true
  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.username, %{})
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end
end
