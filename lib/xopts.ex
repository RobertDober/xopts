defmodule XOpts do
  use XOpts.Types
  alias XOpts.Options
  alias XOpts.Result

  @moduledoc """
  # XOpts a Command Line Argument Parser on Steroids.


  ## Ridiculous Speed Starting Guide

  ### Zero Configuration, (almost) Zero Value

      iex(1)> XOpts.parse([])
      {:ok, %{switches: %{}, keywords: %{}, positionals: [], errors: []}}

      iex(2)> XOpts.parse(~W[alpha beta gamma])
      {:ok, %{switches: %{}, keywords: %{}, positionals: ~W[alpha beta gamma], errors: []}}

      iex(3)> XOpts.parse(~W[:verbose alpha level: 42 beta gamma])
      {:ok, %{switches: %{verbose: true}, keywords: %{level: "42"}, positionals: ~W[alpha beta gamma], errors: []}}

  Posix is widely used and although it is ugly (beauty lies you know in whose eyes), we can accept it by default

      iex(4)> XOpts.parse(~W[--verbose alpha --level 42 beta gamma])
      {:ok, %{switches: %{verbose: true}, keywords: %{level: "42"}, positionals: ~W[alpha beta gamma], errors: []}}

  ### Configure for ~~Great~~ ~~Incredible~~ Ridiculous Value


      iex(5)> configuration = %{
      ...(5)>   allowed_keywords: %{
      ...(5)>     alpha2: {:string, default: "fr"}
      ...(5)>   },
      ...(5)>   required_keywords: %{
      ...(5)>     value: {:int, min: 1} # could be written as: value: :positive_int
      ...(5)>   },
      ...(5)>   allowed_switches: [
      ...(5)>     :verbose, :dry_run, :utf8 ]}
      ...(5)> XOpts.parse(~W[ value: 42 :dry_run some_file])
      {:ok,
        %{
          switches: %{
            dry_run: true,
            utf8: false,
            verbose: false
          },
          keywords: %{
            alpha2: "fr",
            value: 42
          },
          positionals: ~W[some_file],
          errors: []
        }}

      However!!!

      iex(6)> configuration = %{
      ...(6)>   allowed_keywords: %{
      ...(6)>     alpha2: {:string, default: "fr"}
      ...(6)>   },
      ...(6)>   required_keywords: %{
      ...(6)>     value: {:int, min: 1} # could be written as: value: :positive_int
      ...(6)>   },
      ...(6)>   allowed_switches: [
      ...(6)>     :verbose, :dry_run, :utf8 ]}
      ...(6)> XOpts.parse(~W[ min: 2 :foo value: 42 :dry_run some_file])
      {:error,
        %{
          switches: %{
            dry_run: true,
            foo: true,
            utf8: false,
            verbose: false
          },
          keywords: %{
            alpha2: "fr",
            min: "2",
            value: 42
          },
          positionals: ~W[some_file],
          errors: [
            {:forbidden, keyword: :min, value: "2"},
            {:forbidden, switch: :foo}
          ]
        }}


  ## Incredible Speed Starting Guide

  ### Restricting and Typing Keyword Arguments

  As we have seen in the examples configuration can be passed as keyword arguments, however for more
  complex configuration that might become tedious and we therefore will pass in a map.

      iex(7)> configuration = %{
      ...(7)>   allowed_keywords: %{
      ...(7)>     count: :int,
      ...(7)>     message: :string }}
      ...(7)> XOpts.parse(~W[hello count: 42])
      {:ok, %{switches: %{}, keywords: %{count: 42}, positionals: ~W[hello], errors: []}}

  Did you notice the type conversion of the `int` parameter?
  Of course you did!

  Now the user is alerted of misspelled or badly typed arguments:

      iex(8)> configuration = %{
      ...(8)>   allowed_keywords: %{
      ...(8)>     count: :int,
      ...(8)>     message: :string }}
      ...(8)> XOpts.parse(~W[hello cont: 42])
      {:error,
        %{switches: %{},
          keywords: %{}, 
          positionals: ~W[hello], 
          errors: [{:forbidden, keyword: "cont", value: 42}]}}

  She will also be alerted of badly typed arguments

      iex(9)> configuration = %{
      ...(9)>   allowed_keywords: %{
      ...(9)>     count: :int,
      ...(9)>     message: :string }}
      ...(9)> XOpts.parse(~W[hello cont: alpha])
      {:error, 
        %{switches: %{},
          keywords: %{},
          positionals: ~W[hello],
          errors: [{:invalid_type, keyword: "cont", value: "alpha", requested: :int}]}}






  #### Requiring and Typing Keyword Arguments

  Sometimes keyword arguments need to be present

      iex(10)> configuration = %{
      ...(10)>   required_keywords: %{
      ...(10)>     n: :non_negative_int }}
      ...(10)> XOpts.parse(~W[n: 2])
      {:ok, %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: []}}

  and when they are not

      iex(11)> configuration = %{
      ...(11)>   required_keywords: %{
      ...(11)>     n: :non_negative_int }}
      ...(11)> XOpts.parse(~W[n: 2])
      {:ok,
        %{switches: %{}, keywords: %{n: 2}, positionals: ~W[], errors: [{:missing, keyword: "n"}]}}

  or violate a constraint

      iex(12)> configuration = %{
      ...(12)>   required_keywords: %{
      ...(12)>     n: :non_negative_int }}
      ...(12)> XOpts.parse(~W[n: 2])
      {:error,
        %{switches: %{},
          keywords: %{n: 2},
          positionals: [],
          errors: [{:constraint_violation, keyword: "n", value: -1, range: [0]}]}}

  #### A wild combination of errors

      iex(13)> configuration = %{
      ...(13)>    allowed_keywords: %{
      ...(13)>      lang: ~r(\A [[:alnum:]]{2} \z)x},
      ...(13)>    required_keywords: %{
      ...(13)>      base: :any},
      ...(13)>    allowed_switches: []}
      ...(13)> input = ~W[ --verbose lang: frr ]
      ...(13)> XOpts.parse(input, configuration)
      {:error,
        %{
          switches: %{},
          keywords: %{},
          positionals: [],
          errors: [
            {:forbidden, switch: "verbose"},
            {:missing, keyword: "base"},
            {:constraint_violation, keyword: "lang", value: "frr", constraint: ~r(\A [[:alnum:]]{2} \z)x}]}}

  Which was, of course, completely unnecessary

      iex(14)> configuration = %{
      ...(14)>   allowed_keywords: %{
      ...(14)>     lang: ~r(\A [[:alnum:]] {2} \z)x},
      ...(14)>   required_keywords: %{base: :any},
      ...(14)>   allowed_switches: []}
      ...(14)> input = ~W[ lang: fr --base zero cinq ]
      ...(14)> XOpts.parse(input, configuration)
      {:ok,
        %{
          switches: %{},
          keywords: %{base: "zero", lang: "fr"},
          positionals: ~W[cinq],
          errors: []}}

  #### Defaults

  Allowed keyword arguments as well as positionals can have default values

      iex(15)> configuration = %{
      ...(15)>    allowed_keywords: %{
      ...(15)>      n: [:int, default: 42] }}
      ...(15)> XOpts.parse([], configuration)
      {:ok,
        %{switches: %{},
          keywords: %{n: 42},
          poistionals: [],
          errors: []}}

  which, of course can be overridden:

      iex(16)> configuration = %{
      ...(16)>    allowed_keywords: %{
      ...(16)>      n: [:int, default: 42] }}
      ...(16)> XOpts.parse(~W[n: 11], configuration)
      {:ok,
        %{switches: %{},
          keywords: %{n: 11},
          poistionals: [],
          errors: []}}


  #### Strict Order

  The first possibility do assure the Order Of Things (TM: Dominon) is just to assure that keyword arguments and switches come
  before poistional arguments.

  This can be accomplished with the `strict: true` parameter

      iex(17)> XOpts.parse(~W[hello :world], strict: true)
      {:error,
        %{switches: %{}, keywords: %{}, positionals: ~W[hello :world], errors: [
          {:ordered_argument_error, world: "after positional"}
        ]}}

  or simply by calling the `parse_strictly/2` function

      iex(18)> XOpts.parse_strictly(~W[hello :world])
      {:error,
        %{switches: %{}, keywords: %{}, positionals: ~W[hello :world], errors: [
          {:ordered_argument_error, world: "after positional"}
        ]}}

  Of course the _End Of Keywords_ separator `::` or `--` avoid this

      iex(19)> XOpts.parse_strictly(~W[hello :: :world])
      {:ok,
        %{switches: %{}, keywords: %{}, positionals: ~W[hello :world], errors: []}}


  ### Advanced Configuration


  #### Constraints on Positionals


  It might be necessary to request and or restrict the number of positional parameters

  A first example requiring at least two

      iex(20)> configuration = %{
      ...(20)>   nof_postionals: [2]}
      ...(20)> XOpts.parse(~W[a], configuration)
      {:error,
        %{switches: %{}, keywords: %{}, poistionals: ~W[a], errors: [
        {:missing_positional, needed: 2, present: 1}
        ]}
      } 

  Of course Chuck Norris 5th lemma holds: Enough is enough

      iex(21)> configuration = %{
      ...(21)>   nof_postionals: [2]}
      ...(21)> XOpts.parse(~W[a b], configuration)
      {:ok,
        %{switches: %{}, keywords: %{}, poistionals: ~W[a b], errors: []}}

  If we want to restrict the number of positionals it is done with the second number in this list:

      iex(22)> configuration = %{
      ...(22)>   nof_postionals: [1, 2]}
      ...(22)> XOpts.parse(~W[a b c], configuration)
      {:error,
        %{switches: %{}, keywords: %{}, poistionals: ~W[a b c], errors: [
        {:spurious_positional, allowed: 2, present: 3}
        ]}
      } 

  We can also constrain positional parameters

      iex(23)> configuration = %{
      ...(23)>   positional_constraints: [:int, {:string, match: ~r{\AA}}]} # Stupid example but well
      ...(23)> XOpts.parse(~W[ab Bc], configuration)
      {:error,
        %{switches: %{}, keywords: %{}, poistionals: ~W[ab Bc],
          errors: [
            {:constraint_violation, positional: 1, value: "ab", constraint: :int},
            {:constraint_violation, positional: 2, value: "Bc", constraint: ~r{\AA}},
          ]}}

  and use nil for unconstrained positionals between constrained ones:

      iex(24)> configuration = %{
      ...(24)>   positional_constraints: [:int, nil, ~r{\AA}]} # Stupid example but well
      ...(24)> XOpts.parse(~W[ab de Bc], configuration)
      {:error,
        %{switches: %{}, keywords: %{}, poistionals: ~W[ab de Bc],
          errors: [
            {:constraint_violation, positional: 1, value: "ab", constraint: :int},
            {:constraint_violation, positional: 3, value: "Bc", constraint: ~r{\AA}},
          ]}}

  Also note that defining a constraint for a positional parameter does not make it required:

      iex(25)> configuration = %{
      ...(25)>   positional_constraints: [:int, nil, ~r{\AA}]} # Stupid example but well
      ...(25)> XOpts.parse(~W[42 de], configuration)
      {:ok,
        %{switches: %{}, keywords: %{}, poistionals: [42, "de"], errors: []}}

  ### Type Conversions

  Constraints, like `Regex` or `:string` are just checked and if they succeed the
  value is assigned to the keyword or positional argument as is. `:string` *always* succeeds BTW. 

  However there are other builtin types that will, if the check succeeds, coherce the string into a different
  form.

  #### :int type

  ##### Min, Max, Range

  We have already seen an example for that, but there can be constraints added as follows

  For simplicity we will use the imported form for doctests from now on, obviously `parse/1` is imported from
  `XOpts`


      iex(26)> parse(~W[42], positional_constraints: [[:int, max: 40]])
      {:error,
        %{switches: %{}, keywords: %{}, positionals: [42], errors: [
        {:constraint_violation_error, positional: 1, value: 42, max: 40}
        ]}}

  Of course `min` can also be used.

  The parser will also not allow impossible constraints as shown in the next example

      iex(27)> parse([], allowed_keywords: %{n: [:int, min: 10, max: 5]})
      {:illegal_config, [{:empty_range, keyword: :n, min: 10, max: 5}]}

  And defaults need to be in range too:

      iex(28)> parse([], allowed_keywords: %{n: [:int, min: 10, default: 0]})
      {:illegal_config, [{:illegal_default, keyword: :n, min: 10, default: 0}]}

  ##### Concise range specification form

  If we use min and max we can just pass a range

      iex(29)> parse(~W[n: 40], required_keywords: %{n: 41..50})
      {:error,
        %{switches: %{}, keywords: %{n: 40}, positionals: [], errors: [
        {:constraint_violation_error, keyword: :n, value: 40, min: 41, max: 50}
        ]}}

  Oh and let us prove that respecting the requirements yields the results we want, too:

      iex(30)> parse(~W[n: 42], required_keywords: %{n: 41..50})
      {:ok,
        %{switches: %{}, keywords: %{n: 42}, positionals: [], errors: []}}

  Some ranges, even open ones, are predefined, as, e.g.

  ###### `:non_negative_int`

      iex(31)> parse(~W[n: -1], allowed_keywords: %{n: :non_negative_int})
      {:error,
        %{switches: %{}, keywords: %{n: -1}, positionals: [], errors: [
        {:constraint_violation_error, keyword: :n, value: -1, min: 0}
        ]}}

  or

  ###### `:positive_int`

      iex(32)> parse(~W[n: 0], allowed_keywords: %{n: :positive_int})
      {:error,
        %{switches: %{}, keywords: %{n: 0}, positionals: [], errors: [
        {:constraint_violation_error, keyword: :n, value: 0, min: 1}
        ]}}

  ## Great Speed Starting Guide

  ### Posix Or Not Posix?

  If we do not want to parse posix switches or keywords we can disable them

      iex(33)> XOpts.parse(~W[--verbose alpha --level 42 beta gamma], posix: false)
      {:ok, %{switches: %{}, keywords: %{}, positionals: ~W[--verbose alpha --level 42 beta gamma], errors: []}}

  For fairness we can also disable keyword style arguments:

      iex(34)> XOpts.parse(~W[:verbose alpha level: 42 beta gamma], keyword_style: false)
      {:ok, %{switches: %{}, keywords: %{}, positionals: ~W[:verbose alpha level: 42 beta gamma], errors: []}}
  """

  @spec parse(binaries(), Options.user_options_t()) :: xopts_t()
  def parse(input, options \\ []) do
    _parse(input, Options.new(options))
  end

  @spec parse_strictly(binaries(), Options.user_options_t()) :: xopts_t()
  def parse_strictly(input, options \\ []) do
    _parse(input, %{Options.new(options) | strict: true})
  end

  @spec _parse(binaries(), Options.user_options_t()) :: xopts_t()
  defp _parse(input, options)

  defp _parse(_input, options) do
    case Options.check(options) do
      {:ok, _options1} -> {:ok, Map.from_struct(%Result{})}
      {:error, errors} -> {:illegal_config, errors}
    end
  end
end
