defmodule XOpts.Types do
  @moduledoc false

  defmacro __using__(_opts \\ []) do
    quote do
      @type binaries :: list(String.t())

      @type either(ok_t, error_t) :: {:ok, ok_t} | {:error, error_t}

      @type config_error_t :: {:empty_range, Keyword.t()}
              
      @type config_error_ts :: list(config_error_t())

      @type constraint_violation_error :: {:constraint_violation, Keyword.t()}
      @type forbidden_error :: {:forbidden, Keyword.t()}
      @type missing_error :: {:missing, Keyword.t()}
      @type missing_positional_error :: {:missing_positional, Keyword.t()}
      @type ordered_argument_error :: {:ordered_argument_error, Keyword.t()}
      @type spurious_positional_error :: {:spurious_positional, Keyword.t()}
      @type error_t ::
              constraint_violation_error
              | forbidden_error
              | missing_positional_error
              | missing_error
              | ordered_argument_error
              | spurious_positional_error
      @type error_ts :: list(error_t())
      @type non_empty_errors :: [error_t() | error_ts()]

      @type xopts_error_t ::
              {:error,
               %{
                 switches: map(),
                 keywords: map(),
                 positionals: list(),
                 errors: non_empty_errors()
               }}

      @type xopts_illegal_config_t :: {:illegal_config, config_error_ts()}
              
      @type xopts_ok_t ::
              {:ok,
               %{
                 switches: map(),
                 keywords: map(),
                 positionals: list(),
                 errors: []
               }}
      @type xopts_t :: xopts_ok_t() | xopts_error_t() | xopts_illegal_config_t()

      @type maybe(target_t) :: target_t | nil

      @type status :: :ok | :error
      @type stream :: %Stream{} | %File.Stream{}
    end
  end
end
