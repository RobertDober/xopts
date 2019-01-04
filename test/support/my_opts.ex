defmodule Support.MyOpts do
  
  use Xopt

  option :help, :boolean
  option :version, :boolean

  # def debug, do: IO.inspect(@_option_definitions)
end
