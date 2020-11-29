defmodule X2048.Game do
  alias X2048.Grid
  use GenServer

  ### Server

  def init_game() do
    %{mode: :anarchy,
      ended?: false,
      votes: %{},
      grid: Grid.init_grid()}
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_player, game_id, username}, _from, state) do
    case Map.get(state, game_id) do
      nil ->
        game = init_game() |> put_vote(username, nil)
        {:reply, game, Map.put(state, game_id, game)}
      game ->
        new_game = put_vote(game, username, nil)
        {:reply, new_game, %{state | game_id => new_game}}
    end
  end

  def handle_call({:turn, username, game_id, direction}, _from, state) do
    %{^game_id => game} = state
    case game do
      %{ended?: true} ->
        {:reply, game, state}
      %{mode: :democracy} ->
        game_with_vote = put_vote(game, username, direction)
        case vote_result(game_with_vote) do
          {:ok, consensus_direction} ->
            new_game =
              game |> flush_votes() |> turn_grid(consensus_direction)
              {:reply, new_game, %{state | game_id => new_game}}
          _ ->
            {:reply, game_with_vote, %{state | game_id => game_with_vote}}
        end
      %{mode: :anarchy} ->
        new_game = turn_grid(game, direction)
        {:reply, new_game, %{state | game_id => new_game}}
    end
  end

  def handle_call({:toggle_mode, game_id}, _from, state) do
    %{^game_id => %{mode: mode} = game} = state
    new_mode =
      case mode do
        :anarchy -> :democracy
        :democracy -> :anarchy
      end
    new_game = %{game | mode: new_mode}
    {:reply, new_game, %{state | game_id => new_game}}
  end

  def handle_call({:put_obstacle, game_id}, _from, state) do
    %{^game_id => %{grid: grid} = game} = state
    grid = Grid.put_random_tile(grid, :obstacle)
    game = %{game | grid: grid}
    {:reply, game, %{state | game_id => game}}
  end

  def handle_call({:drop_obstacle, game_id}, _from, state) do
    %{^game_id => %{grid: grid} = game} = state
    grid = Grid.drop_random_obstacle(grid)
    game = %{game | grid: grid}
    {:reply, game, %{state | game_id => game}}
  end

  @impl true
  def handle_cast({:drop_player, game_id, username}, state) do
    %{^game_id => %{votes: votes} = game} = state
    new_game = %{game | votes: Map.delete(votes, username)}
    {:noreply, %{state | game_id => new_game}}
  end

  ### Client

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end

  def vote_result(%{votes: votes}) do
    count = Enum.count(votes)
    {top_vote, votes} =
      votes
      |> Enum.group_by(fn {_k, v} -> v end)
      |> Enum.max_by(fn {_direction, votes} -> length(votes) end)
    if length(votes) / count > 0.5 && top_vote != nil do
      {:ok, top_vote}
    else
      :error
    end
  end

  def flush_votes(%{votes: votes} = game) do
    new_votes =
      votes
      |> Enum.map(fn {k, _v} -> {k, nil} end)
      |> Enum.into(%{})
    %{game | votes: new_votes}
  end

  def put_vote(%{votes: votes} = game, username, direction) do
    %{game | votes: Map.put(votes, username, direction)}
  end

  def turn_grid(%{grid: grid} = game, direction) do
    new_grid = Grid.move(grid, direction)
    cond do
      new_grid == grid -> game
      Grid.goal_reached?(new_grid) -> %{game | grid: new_grid, ended?: true}
      true -> %{game | grid: Grid.put_random_tile(new_grid, 2)}
    end
  end

  def add_player(game_id, username) do
    GenServer.call(__MODULE__, {:add_player, game_id, username})
    |> transform_grid_to_matrix()
  end

  def turn(username, game_id, direction) do
    GenServer.call(__MODULE__, {:turn, username, game_id, direction})
    |> transform_grid_to_matrix()
  end

  def put_obstacle(game_id) do
    GenServer.call(__MODULE__, {:put_obstacle, game_id})
    |> transform_grid_to_matrix()
  end

  def drop_obstacle(game_id) do
    GenServer.call(__MODULE__, {:drop_obstacle, game_id})
    |> transform_grid_to_matrix()
  end

  def drop_player(game_id, username) do
    GenServer.cast(__MODULE__, {:drop_player, game_id, username})
  end

  def toggle_mode(game_id) do
    GenServer.call(__MODULE__, {:toggle_mode, game_id})
    |> transform_grid_to_matrix()
  end


  def transform_grid_to_matrix(%{grid: grid} = game) do
    new_grid = Grid.to_matrix(grid)
    %{game | grid: new_grid}
  end
end
