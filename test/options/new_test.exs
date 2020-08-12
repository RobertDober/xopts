defmodule Options.NewTest do
  use ExUnit.Case

  alias XOpts.Options
  import Options, only: [new: 1]

  describe "new" do
    test "from empty list" do
      expected = %Options{}
      assert new([]) == expected
    end
    test "from empty hash" do
      expected = %Options{}
      assert new(%{}) == expected
    end
    test "from default struct" do
      expected = %Options{}
      assert new(struct(Options)) == expected
    end
  end

  describe "changing values" do
    test "allowed_keywords from Keyword ;)" do
      expected = %Options{allowed_keywords: %{}}
      assert new(allowed_keywords: %{}) == expected
    end

    test "requested_keywords and posix from map" do
      expected = %Options{requested_keywords: %{n: :int}, posix: false}
      assert new(%{requested_keywords: %{n: :int}, posix: false}) == expected
    end
  end
  
end
