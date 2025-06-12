defmodule Dictionary.Runtime.Server do
  @type t :: pid()

  def start_link do
    Agent.start_link(&Dictionary.Impl.WordList.word_list/0, name: __MODULE__)
  end

  def random_word() do
    Agent.get(__MODULE__, &Dictionary.Impl.WordList.random_word/1)
  end
end
