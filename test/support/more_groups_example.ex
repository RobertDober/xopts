defmodule Support.MoreGroupsExample do
  use XOpts

  group :city, exclusive: true do
    option :narbonne
    option :limoux
    option :carcassonne
  end

  option :count, :integer

  group :language, allowed: 1..4 do
    options [:en, :fr, :it, :oc, :pt]
  end

  def xoptions, do: @_xoptions
  
end
