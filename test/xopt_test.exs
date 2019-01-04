defmodule XoptTest do
  use ExUnit.Case
  doctest Xopt

  describe "simple options" do

    test "boolean options" do
      IO.inspect MyOpts.debug
      assert MyOpts.parse(["--help"]).present?(:help)
      assert MyOpts.parse(["--help"]).valid?
      # assert MyOpts.parse(["--help"]).options == %MyOpts{help: true}
    end
  end
end
