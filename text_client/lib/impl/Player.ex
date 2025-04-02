defmodule TextClient.Impl.Player do
  @typep game :: Hangman.Game
  @typep tally :: Hangman.tally()
  @typep state :: {game, tally}

  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  def interact({_game, _tally = %{game_state: :won}}), do: "You won"

  def interact({_game, tally = %{game_state: :lost}}),
    do: "You lost... the word was #{tally.letters |> Enum.join()}"

  def interact({game, tally}) do
    IO.puts(feedback_for(tally))
    IO.puts(current_word(tally))
    Hangman.make_move(game, next_guess())
    |> interact()
  end

  def feedback_for(tally = %{game_state: :initializing}) do
    "Welcome, I'm thinking of a word with #{tally.letters |> length} letters"
  end

  def feedback_for(%{game_state: :good_guess}) do
    "Good guess"
  end

  def feedback_for(%{game_state: :bad_guess}) do
    "Bad guess"
  end

  def feedback_for(%{game_state: :already_used}) do
    "You already used this word"
  end

  def current_word(tally) do
    IO.puts(
      [
        "Word so far",
        tally.letters |> Enum.join(),
        ", turns lef: ",
        tally.turns_left |> to_string(),
        ", used so far: ",
        tally.used |> Enum.join()
      ]
    )
  end

  def next_guess do
    IO.gets("Next word: ")
    |> String.trim()
    |> String.downcase()
  end
end
