defmodule Disco do
  @moduledoc """
  Documentation for `Disco`.
  """

  def add_target_capability_tag(tag) do
    Disco.Server.add_target_capability_tag(tag)
  end

  def add_local_capability(tag, cap) do
    Disco.Server.add_local_capability(tag, cap)
  end

  def fetch_capabilities(tag) do
    Disco.Server.fetch_capabilities(tag)
  end

  def swap_capabilities() do
    Disco.Server.swap_capabilities()
  end
end
