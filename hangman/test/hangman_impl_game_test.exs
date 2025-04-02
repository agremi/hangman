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

  test "a not-duplicate letters is put inside used" do
    game = Game.new_game()
    {new_game, _tally} = Game.make_move(game, "w")
    {new_game, _tally} = Game.make_move(new_game, "y")
    assert MapSet.equal?(new_game.used, MapSet.new(["w", "y"]))
  end

  test "we recognize a letter in a word" do
    game = Game.new_game("train")
    # guess t
    {new_game, tally} = Game.make_move(game, "t")
    assert Enum.member?(new_game.letters, "t")
    assert tally.game_state == :good_guess
    # # guess r
    {new_game, tally} = Game.make_move(game, "r")
    assert Enum.member?(new_game.letters, "r")
    assert tally.game_state == :good_guess
  end

  test "we recognize a letter not in the word" do
    game = Game.new_game("train")

    {new_game, tally} = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess
  end

  test "can handle a list of moves" do
    # guessing  hello word
    [
      # guess | state | left | letters         | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a winning game" do
    # guessing "hello" word
    [
      # guess | state | left | letters | used
      ["e", :good_guess, 7, ["_", "e", "_", "_", "_"], ["e"]],
      ["a", :bad_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["l", :good_guess, 6, ["_", "e", "l", "l", "_"], ["a", "e", "l"]],
      ["i", :bad_guess, 5, ["_", "e", "l", "l", "_"], ["a", "e", "i", "l"]],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], ["a", "e", "i", "l", "o"]],
      ["h", :won, 5, ["h", "e", "l", "l", "o"], ["a", "e", "h", "i", "l", "o"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    # guessing "hello" word (losing game)
    [
      # guess | state | left | letters | used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["b", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "b"]],
      ["c", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "b", "c"]],
      ["d", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d"]],
      ["e", :good_guess, 3, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e"]],
      ["f", :bad_guess, 2, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f"]],
      ["g", :bad_guess, 1, ["_", "e", "_", "_", "_"], ["a", "b", "c", "d", "e", "f", "g"]],
      ["i", :lost, 0, ["h", "e", "l", "l", "o"], ["a", "b", "c", "d", "e", "f", "g", "i"]]
    ]
    |> test_sequence_of_moves()
  end

  ####################### UTILITY FUNCTIONS ########################################

  defp test_sequence_of_moves(moves) do
    game = Game.new_game("hello")
    Enum.reduce(moves, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used
    game
  end
end
