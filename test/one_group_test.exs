defmodule OneGroupTest do
  use ExUnit.Case
  alias Support.OneGroupExample, as: Example
  
  test "correct xoptions" do
    assert Example.xoptions == 
      [ {:gamma, :boolean, []},
        {:alpha, :boolean, [group: :greek]},
        {:beta, :boolean, [group: :greek]}
      ]
  end
end
