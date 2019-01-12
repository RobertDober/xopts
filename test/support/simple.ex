defmodule Support.Simple do
  
  use XOpts

  option :help, :boolean
  option :verbose, :boolean, true
  option :count, :integer, 42

end
