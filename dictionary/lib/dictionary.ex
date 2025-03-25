defmodule Dictionary do
  @words_list "assets/words(1).txt"
              |> File.read!()
              |> String.split(~r/\n/, trim: true)

  def random_word do
    @words_list
    |> Enum.random()
  end
end
