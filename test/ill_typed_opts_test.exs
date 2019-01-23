defmodule IllTypedOptsTest do
  use ExUnit.Case

  alias Support.IllTypedOption
  alias XOpts.Error

  test "required option is present" do
    assert_raise(Error, fn -> 
      Code.compile_file("test/support/ill_typed_option.exs")
    end)
  end
  
end
