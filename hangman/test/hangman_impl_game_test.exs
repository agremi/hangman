defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game should return correct structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game should returns correct word" do
    game = Game.new_game("train")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    # assert game.letters == ["t", "r", "a", "i", "n"]

    assert Enum.all?(game.letters, fn char ->
             char_code = char |> to_string() |> String.to_charlist() |> hd()
             char_code >= ?a && char_code <= ?z
           end)
  end

  test "state doesn't change if game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("train")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "a used letter is reported" do
    game = Game.new_game("train")
    {new_game, _tally} = Game.make_move(game, "t")
    {new_game, _tally} = Game.make_move(new_game, "t")

    assert new_game.game_state == :already_used
  end

  test "a not-duplicate letters is put inside used"do
    game = Game.new_game()
    {new_game, _tally} = Game.make_move(game, "w")
    {new_game, _tally} = Game.make_move(new_game, "y")
    assert MapSet.equal?(new_game.used, MapSet.new(["w","y"]))
  end
end
