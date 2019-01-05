defmodule MyOpts do
  
  use XOpts

  option :help, :boolean
  option :count, :integer, 42


end
