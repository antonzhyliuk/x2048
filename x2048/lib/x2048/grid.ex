defmodule X2048.Grid do

  def init_grid() do
    for x <- 1..6, y <- 1..6 do
      %{x: x, y: y, val: nil}
    end
    |> put_random_tile(2)
  end

  def to_matrix(grid) do
    grid
      |> Enum.group_by(&(&1[:y]))
      |> Enum.sort_by(fn {y, _xs} -> y end, :desc)
      |> Enum.map(fn {_y, xs} ->
        xs
        |> Enum.sort_by(fn %{x: x} -> x end)
        |> Enum.map(fn el -> el[:val] end)
      end)
  end

  def drop_random_obstacle(grid) do
    case Enum.filter(grid, &(&1[:val] == :obstacle)) do
      [] ->
        grid
      obstacles ->
        obstacle_tile = Enum.random(obstacles)
        put_tile(grid, %{obstacle_tile | val: nil})
    end
  end

  def goal_reached?(grid) do
    Enum.any?(grid, &(&1[:val] == 2048))
  end

  def put_tile(grid, %{x: x, y: y} = tile) do
    Enum.map(grid, fn t ->
      if t[:x] == x && t[:y] == y, do: tile, else: t
    end)
  end

  def put_random_tile(grid, val) do
    random_available_tile =
      grid
      |> Enum.filter(fn tile -> is_nil(tile[:val]) end)
      |> Enum.random()
    put_tile(grid, %{random_available_tile | val: val})
  end

  def movement("right"), do: {:y, :x, :desc}
  def movement("left"),  do: {:y, :x, :asc}
  def movement("up"),    do: {:x, :y, :desc}
  def movement("down"),  do: {:x, :y, :asc}

  def move(grid, direction) do
    {group_axis, sort_axis, sort_direction} = movement(direction)

    grid
    |> Enum.group_by(&(&1[group_axis]))
    |> Enum.sort_by(fn {group_axis_idx, _} -> group_axis_idx end)
    |> Enum.flat_map(fn {group_axis_idx, group} ->
      group
      |> Enum.sort_by(&(&1[sort_axis]), sort_direction)
      |> Enum.map(&(&1[:val]))
      |> split_by_obstacle()
      |> Enum.map(&squash_tiles/1)
      |> List.flatten()
      |> Enum.zip(case sort_direction do
        :asc -> 1..6
        :desc -> 6..1
      end)
      |> Enum.map(fn {val, sort_axis_idx} ->
        %{group_axis => group_axis_idx,
          sort_axis => sort_axis_idx,
          val: val}
      end)
    end)
  end

  def split_by_obstacle(list), do: split_by_obstacle(list, [], [])
  def split_by_obstacle([], sub, result) do
    Enum.map([sub | result], &Enum.reverse/1) |> Enum.reverse()
  end
  def split_by_obstacle([:obstacle | rest], sub, result) do
    split_by_obstacle(rest, [], [[:obstacle] | [sub | result] ])
  end
  def split_by_obstacle([val | rest], sub, result) do
    split_by_obstacle(rest, [val | sub], result)
  end


  def squash_tiles([]), do: []
  def squash_tiles([v]), do: [v]
  def squash_tiles([h|t]) do
    {vals, nils} =
      Enum.reduce(t, [h], fn
        (nil, acc) -> acc ++ [nil]
        (el, [v|rest]) when el == v and v != nil -> [nil | [el + v | rest]]
        (el, acc) -> [el|acc]
      end)
      |> Enum.split_with(&Function.identity/1)
    Enum.reverse(vals) ++ nils
  end
end
