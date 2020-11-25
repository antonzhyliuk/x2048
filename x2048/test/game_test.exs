defmodule X2048.GameTest do
  use ExUnit.Case, async: true

  describe "squash_tiles/1 squash line to left: " do
    test "2 2 2 -> 4 2 nil" do
      assert X2048.Game.squash_tiles([2, 2, 2]) == [4, 2, nil]
    end

    test "2 2 2 2 -> 4 4 nil nil " do
      assert X2048.Game.squash_tiles([2, 2, 2, 2]) == [4, 4, nil, nil]
    end

    test "4 4 4 4 4 4 -> 8 8 8 nil nil nil" do
      assert X2048.Game.squash_tiles([4, 4, 4, 4, 4, 4]) == [8, 8, 8, nil, nil, nil]
    end

    test "2 4 nil 4 -> 2 8 nil nil" do
      assert X2048.Game.squash_tiles([2, 4, nil, 4]) == [2, 8, nil, nil]
    end

    test "2 -> 2" do
      assert X2048.Game.squash_tiles([2]) == [2]
    end

    test "[] -> []" do
      assert X2048.Game.squash_tiles([]) == []
    end
  end

  # o - nil, x - obstacle
  describe "split_by_obstacle/1 chops line to the sublines by obstacle" do
    test "2 4 o 2 x 2 o x -> 2 4 o 2 | x | 2 o | x |" do
      actual = X2048.Game.split_by_obstacle([2, 4, nil, 2, :obstacle, 2, nil, :obstacle])
      expected = [[2, 4, nil, 2], [:obstacle], [2, nil], [:obstacle], []]
      assert actual == expected
    end

    test "o x x 2 o -> o | x | x | 2 o" do
      actual = X2048.Game.split_by_obstacle([nil, :obstacle, :obstacle, 2, nil])
      expected = [[nil], [:obstacle], [], [:obstacle], [2, nil]]
      assert actual == expected
    end

    test "x 2 4 x o -> | x | 2 4 | x | o" do
      actual = X2048.Game.split_by_obstacle([:obstacle, 2, 4, :obstacle, nil])
      expected = [[], [:obstacle], [2, 4], [:obstacle], [nil]]
      assert actual == expected
    end
  end

  describe "Grid movements: " do
    def put_tiles(grid, tiles) do
      Enum.reduce(tiles, grid, fn tile, grid ->
        X2048.Game.put_tile(grid, tile)
      end)
    end

    def assert_grid(grid, tiles) do
      grid_tiles = Enum.filter(grid, &(&1[:val] != nil))
      assert Enum.sort(grid_tiles) == Enum.sort(grid_tiles)
    end

    setup do
      grid =
        X2048.Game.init_grid()
        |> put_tiles([
          %{x: 3, y: 6, val: 2},
          %{x: 6, y: 6, val: 2},
          %{x: 2, y: 5, val: 2},
          %{x: 2, y: 3, val: 4},
          %{x: 6, y: 3, val: 2},
          %{x: 4, y: 2, val: 2}
        ])
      {:ok, grid: grid}
    end

    test "right", %{grid: grid} do
      X2048.Game.move(grid, "right")
      |> assert_grid([
        %{x: 6, y: 6, val: 4},
        %{x: 6, y: 5, val: 2},
        %{x: 5, y: 3, val: 4},
        %{x: 6, y: 3, val: 2},
        %{x: 6, y: 2, val: 2}
      ])
    end

    test "left", %{grid: grid} do
      X2048.Game.move(grid, "left")
      |> assert_grid([
        %{x: 1, y: 6, val: 4},
        %{x: 1, y: 5, val: 2},
        %{x: 2, y: 3, val: 4},
        %{x: 1, y: 3, val: 2},
        %{x: 1, y: 2, val: 2}
      ])
    end

    test "down", %{grid: grid} do
      X2048.Game.move(grid, "down")
      |> assert_grid([
        %{x: 2, y: 2, val: 2},
        %{x: 2, y: 1, val: 4},
        %{x: 3, y: 1, val: 2},
        %{x: 4, y: 1, val: 2},
        %{x: 6, y: 1, val: 4}
      ])
    end

    test "up", %{grid: grid} do
      X2048.Game.move(grid, "up")
      |> assert_grid([
        %{x: 2, y: 5, val: 2},
        %{x: 2, y: 6, val: 4},
        %{x: 3, y: 6, val: 2},
        %{x: 4, y: 6, val: 2},
        %{x: 6, y: 6, val: 4}
      ])
    end
  end
end
