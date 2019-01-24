defmodule Xopts.MoreGroupsTest do
  use ExUnit.Case
  
  alias Support.MoreGroupsExample, as: Example

  test "xoptions" do
    assert Example.xoptions == 
      [
        {:pt, :boolean, [group: :language, min: 1, max: 4]},
        {:oc, :boolean, [group: :language, min: 1, max: 4]},
        {:it, :boolean, [group: :language, min: 1, max: 4]},
        {:fr, :boolean, [group: :language, min: 1, max: 4]},
        {:en, :boolean, [group: :language, min: 1, max: 4]},
        {:count, :integer, []},
        {:carcassonne, :boolean, [group: :city, max: 1]},
        {:limoux, :boolean, [group: :city, max: 1]},
        {:narbonne, :boolean, [group: :city, max: 1]},
      ]
  end

  
end
