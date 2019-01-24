defmodule Support.OneGroupExample do
  use XOpts

  group :greek do
    option :beta
    option :alpha
  end
  option :gamma, :boolean

  def xoptions, do: @_xoptions
  
end
