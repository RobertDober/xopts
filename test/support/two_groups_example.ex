defmodule Support.TwoGroupsExample do
  use XOpts

  group :latin do
    option :i
    option :ii
    option :iii
  end

  option :version, :string, required: true
  option :lang, :string, default: "elixir"

  group :greek do
    option :alpha
    option :beta
    option :gamma
  end

  def xoptions, do: @_xoptions
end
