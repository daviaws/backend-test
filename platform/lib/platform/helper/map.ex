defmodule Platform.Helper.Map do
  @moduledoc """
  Helper to handle maps.
  """

  @doc """
  Convert map string keys to :atom keys
  """
  def atomize_keys(nil), do: nil

  # Structs don't do enumerable and anyway the keys are already
  # atoms
  def atomize_keys(%{__struct__: _} = struct) do
    struct
  end

  def atomize_keys(%{} = map) do
    Enum.into(map, %{}, fn
      {k, v} when is_atom(k) -> {k, atomize_keys(v)}
      {k, v} -> {String.to_atom(k), atomize_keys(v)}
    end)
  end

  # Walk the list and atomize the keys of
  # of any map members
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end
end
