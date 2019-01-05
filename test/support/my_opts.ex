defmodule Support.MyOpts do
  
  use XOpts

  def options, do: [
    help: :boolean,
    version: :boolean
  ]

end
