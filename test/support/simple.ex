defmodule Support.Simple do
  
  use XOpts

  option :help, :boolean
  option :verbose, {:boolean, true}
  option :count, {:integer, 42}

  def show_options, do: @_xoptions
end
