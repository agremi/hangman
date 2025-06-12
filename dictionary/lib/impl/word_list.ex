defmodule Dictionary.Impl.WordList do
  @type t :: list(String)

  @spec word_list() :: t
  def word_list do
    "assets/words(1).txt"
    |> File.read!()
    |> String.split(~r/\n/, trim: true)
  end

  @spec random_word(t) :: String.t()
  def random_word(words_list) do
    Enum.random(words_list)
  end
end
