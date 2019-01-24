defmodule XOpts.MacroState do

  use Agent
  
  defstruct current_group: nil, xoptions: []


  @doc false
  def start_link(module) do
    Agent.start_link( fn -> %__MODULE__{} end, name: module )
  end

  def get_group(module), do: Agent.get( module, &(&1.current_group) )
  def get_state(module), do: Agent.get( module, &({&1.current_group, &1.xoptions}) )
  def get_xoptions(module), do: Agent.get( module, &(&1.xoptions) )

  def set_group(module, group) do
    Agent.update( module, fn state -> %{state | current_group: group} |> IO.inspect end )
  end

  def add_xoption(module, xoption) do
    Agent.update( module, fn state -> %{state | xoptions: [xoption|state.xoptions]} |> IO.inspect end )
  end

end
