defmodule XOpts.ToolsTest do
  use ExUnit.Case

  alias XOpts.Group
  import XOpts.Tools

  @xoptions [
    {:regex, :boolean, :group, :parser},
    {:group_option, :all, :parser, nil},
    {:group_option, :all_formats, :formats, nil},
    {:verbose, :boolean, true, nil},
    {:linux, :boolean, :group, :os}
  ]

  describe "w/o groups" do
    test "empty" do
      result = make_options([], [], %{}, [])

      assert result == []
    end
  end

  describe "w/o actual values, usage inside the macro" do 
    test "creates a kwlist suitable for `defstruct`" do 
      result = make_options(@xoptions, [], %{}, [])
      
      assert result == [linux: false, verbose: true, all_formats: false, all: false, regex: false]
    end
  end

  describe "with actual values, usage inside the parser" do
    @actual_values [
      regex: true,
      verbose: false
    ]
    test "creates a kwlist with actual values provided" do 
      result = make_options(@xoptions, @actual_values, %{}, [])
      
      assert result == [linux: false, verbose: false, all_formats: false, all: false, regex: true]
    end

    @grouped_options [
      {:regex, :boolean, :group, :parser},
      {:leex, :boolean, :group, :parser},
      {:group_option, :all, :parser, nil},
      {:verbose, :boolean, nil, nil}
    ]
    @grouped_values [
      leex: true,
      all: true
    ]
    @groups %{
      parser: %Group{all_selected?: true}
    }
    test "but if groups are selected than we set all values here" do
      result = make_options(@grouped_options, @grouped_values, @groups, [])

      assert result == [verbose: false, all: true, leex: true, regex: true]
    end
  end

  
end
