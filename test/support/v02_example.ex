defmodule Support.V02Example do
  use XOpts

  group :greek do
    option :beta, :boolean
  end
  option :gamma, :boolean

  def xoptions, do: @_xoptions
  
end
