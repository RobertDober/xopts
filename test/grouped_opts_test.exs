defmodule GroupedOptsTest do
  use ExUnit.Case

  alias Support.GroupedOpts, as: G
  alias Support.GroupedOpts.XOpts, as: X

  describe "single option selected" do
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

  describe "multiple options selected" do 
    test "--recursive and --regex" do
      {:ok, result} = G.parse(~w{--recursive and --regex})
      assert result == %X{
        groups: %{
          parser: %{leex: false, recursive: true, regex: true}
        },
        is: %{errors: [], valid: true},
        options: %{leex: false, recursive: true, regex: true, all: false},
        args: ["and"],
        leex: false,
        recursive: true,
        regex: true,
        all: false
      }
    end
  
    test "--all" do
      {:ok, result} = G.parse(~w{--all and})
      assert result == %X{
        groups: %{
          parser: %{leex: true, recursive: true, regex: true}
        },
        is: %{errors: [], valid: true},
        options: %{leex: true, recursive: true, regex: true, all: true},
        args: ["and"],
        leex: true,
        recursive: true,
        regex: true,
        all: true
      }
    end
    
  end
end
