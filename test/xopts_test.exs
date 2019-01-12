defmodule XoptTest do
  use ExUnit.Case

  alias Support.Simple
  doctest XOpts

  describe "created XOpts struct" do
    test "with defaults" do
      x = %Simple.XOpts{}
      refute x.help
      assert x.verbose
      assert x.count == 42
    end

    test "can be set by parsing" do
      {:ok, parsed} = Simple.parse(~w{--no-verbose --count=11})
      %Simple.XOpts{verbose: verbose} = parsed
      refute verbose
      assert Enum.empty?(parsed.args)
      assert parsed.options == %{verbose: false, count: 11, help: false} 
    end
  end

  describe "simple options" do

    test "boolean option" do
      {:ok, %{help: help, verbose: verbose}=result} = Simple.parse(~w[--help --no-verbose])
      assert help
      refute verbose
      assert result.is.valid
    end

    test "two boolean options" do
      {:ok, result} = Simple.parse(["--help", "--verbose"])
      assert result.options == %{help: true, count: 42, verbose: true}
    end

    test "and args" do
      {:ok, result} = Simple.parse(~w{--help --verbose arg1 arg2})
      assert result.is.valid
      assert result.options == %{count: 42, help: true, verbose: true}
      assert result.args == ~w{arg1 arg2}
      assert Enum.empty?(result.is.errors)
    end
  end
end
