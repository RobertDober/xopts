defmodule XoptTest do
  use ExUnit.Case

  alias Support.Simple
  doctest XOpts

  describe "created XOpts struct" do
    test "exists" do
      x = %Simple.XOpts{}
      refute x.help
      assert x.verbose
      assert x.count == 42
    end

    test "can be set by parsing" do
      {:ok, parsed} = Simple.parse(~w{--no-verbose --count=11})
      refute parsed.verbose
      assert Enum.empty?(parsed.args)
    end
  end
  # describe "simple options" do

  #   test "boolean option" do
  #     assert Simple.parse(["--help"]).options == %{help: true}
  #     assert Simple.parse(["--help"]).is.valid?
  #   end

  #   test "two boolean options" do
  #     assert Simple.parse(["--help", "--version"]).options == %{help: true, version: true}
  #     assert Simple.parse(["--help"]).options == %{help: true}
  #     # assert Simple.parse(["--help"]).options == %Simple{help: true}
  #   end

  #   test "and args" do
  #     options = Simple.parse(~w{--help --version arg1 arg2})
  #     assert options.is.valid?
  #     assert options.options == %{help: true, version: true}
  #     assert options.args == ~w{arg1 arg2}
  #     assert Enum.empty?(options.errors)

  #   end
  # end
end
