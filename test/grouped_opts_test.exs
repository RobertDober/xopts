defmodule GroupedOptsTest do
  use ExUnit.Case

  alias Support.GroupedOpts, as: G
  alias Support.GroupedOpts.XOpts, as: X

  describe "single options selected" do
    test "--leex" do
      {:ok, result} = G.parse(~w{--leex})
      assert result == %X{
        groups: %{
          parser: %{leex: true, recursive: false, regex: false}
        },
        is: %{errors: [], valid: true},
        options: %{leex: true, recursive: false, regex: false, all: false},
        args: [],
        leex: true,
        recursive: false,
        regex: false,
        all: false
      }
    end
  end
end
