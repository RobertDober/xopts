defmodule XOpts.Types do

  defmacro __using__(_opts \\ []) do
    quote do
      @type map_with_keys(key) :: %{key => any()}
      @type map_with_keys(k1, k2) :: %{k1 => any(), k2 => any()}
      @type pair(lhs, rhs) :: {lhs, rhs}
      @type pair_of(t) :: pair(t, t)
    end
  end

end
