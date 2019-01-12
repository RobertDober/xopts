defmodule XOpts.GroupTest do
  use ExUnit.Case

  alias XOpts.Group
  import XOpts.Groups

  describe "empty result" do
    test "empty xopitons, empty switches" do
      result = extract_groups([], [], %{})

      assert result == %{}
    end

    test "empty xoptions -> switches have no influence" do
      result = extract_groups([], [hello: true], %{})

      assert result == %{}
    end

    @xoptions [
      {:help, :boolean, nil, nil},
      {:version, :string, "42", nil}
    ]
    test "xoptions w/o groups" do
      result = extract_groups(@xoptions, [hello: true], %{})

      assert result == %{}
    end
  end

  describe "groups present" do
    @one_group [
      {:regex, :boolean, :group, :parser}
    ]
    test "just a group" do
      result = extract_groups(@one_group, [], %{})

      assert result == %{parser: %Group{all_selected?: false, values: %{regex: nil}}}
    end

    @one_group_option [
      {:group_option, :all, :parser, nil}
    ]
    test "just one group by group_options" do
      result = extract_groups(@one_group_option, [], %{})

      assert result == %{parser: %Group{all_selected?: false, values: %{}}}
    end
    test "just one group by group_options, but selected" do
      result = extract_groups(@one_group_option, [xxx: false, all: true], %{})

      assert result == %{parser: %Group{all_selected?: true, values: %{}}}
    end
  end

  describe "complex example" do
    @xoptions [
      {:regex, :boolean, :group, :parser},
      {:group_option, :all, :parser, nil},
      {:group_option, :all_formats, :formats, nil},
      {:verbose, :boolean, nil, nil},
      {:linux, :boolean, :group, :os}
    ]
    @switches [
      all: false,
      all_formats: true,
      linux: true
    ]
    test "returns correct groups" do
      result = extract_groups(@xoptions, @switches, %{})

      assert result == %{
        formats: %Group{all_selected?: true, values: %{}},
        os: %Group{all_selected?: false, values: %{linux: nil}},
        parser: %Group{all_selected?: false, values: %{regex: nil}}}

    end
  end


end
