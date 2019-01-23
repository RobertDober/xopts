defmodule RequiredOptsTest do
  use ExUnit.Case

  alias Support.RequiredOpts

  test "required option is present" do
    {:ok, result} = RequiredOpts.parse(~w{--level 42})
    assert result == %Support.RequiredOpts.XOpts{
               args: [],
               groups: %{},
               is: %{errors: [], valid: true},
               level: 42,
               options: %{level: 42}
             }
  end

  test "required option does not have a value" do
    {:error, result} = RequiredOpts.parse(~w{--level})
    assert result == [{"--level", nil}]
  end

  test "required option is not present" do
    {:ok, result} = RequiredOpts.parse(~w{})
    assert result == %RequiredOpts.XOpts{
              args: [],
              groups: %{},
              is: %{
                errors: ["Error, missing required option `level:integer`"],
                valid: false
              },
              level: 0,
              options: %{level: 0}
            }

  end
  
end
