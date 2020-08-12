defmodule XOpts.Types do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @type binaries :: list(String.t())

      @type either(ok_t, error_t) :: {:ok, ok_t} | {:error, error_t}

      @type missing_error :: {:missing, Keyword.t()}
      @type forbidden_error :: {:forbidden, Keyword.t()}
      @type constraint_violation_error :: {:constraint_violation, Keyword.t()}
      @type error_t :: forbidden_error | missing_error | constraint_violation_error
      @type error_ts :: list(error_t())
      @type non_empty_errors :: [error_t() | error_ts()]

      @type result_t(rt) :: {:ok, rt, []} | {:error, rt, error_ts()}


      @type maybe(target_t) :: target_t | nil

      @type status :: :ok | :error
      @type stream :: %Stream{} | %File.Stream{}
    end
  end
end
