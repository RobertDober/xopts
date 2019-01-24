defmodule XOpts2Test do
  use ExUnit.Case
  
  alias Support.V02Example, as: Example

  test "accessing" do
    assert Example.xoptions == [ 
      {:gamma, :boolean, :group, nil},
      {:beta, :boolean, :group, :greek},
    ] 
  end
end
