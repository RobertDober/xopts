defmodule TwoGroupsTest do
  use ExUnit.Case
  
  alias Support.TwoGroupsExample, as: Example2

  test "correct xoptions" do
    assert Example2.xoptions == 
      [ 
        {:gamma, :boolean, [group: :greek]},
        {:beta, :boolean, [group: :greek]},
        {:alpha, :boolean, [group: :greek]},
        {:lang, :string, [default: "elixir"]},
        {:version, :string, [required: :true]},
        {:iii, :boolean, [group: :latin]},
        {:ii, :boolean, [group: :latin]},
        {:i, :boolean, [group: :latin]},
      ]
  end
end
