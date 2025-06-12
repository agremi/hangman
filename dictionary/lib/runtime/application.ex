defmodule Dictionary.Runtime.Application do
  use Application

  def start(_start_type, _start_args) do
    Dictionary.Runtime.Server.start_link()
  end
end
