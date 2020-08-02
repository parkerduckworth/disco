defmodule Disco.Server do
  use GenServer

  alias Disco.Server.State

  defmodule State do
    defstruct [
      :target_capabilities,
      :local_capabilities,
      :discovered_capabilities
    ]
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_target_capability_tag(tag) do
    GenServer.cast(__MODULE__, {:add_target_capability_tag, tag})
  end

  def add_local_capability(tag, cap) do
    GenServer.cast(__MODULE__, {:add_local_capability, {tag, cap}})
  end

  def fetch_capabilities(tag) do
    GenServer.call(__MODULE__, {:fetch_capabilities, tag})
  end

  def swap_capabilities() do
    GenServer.cast(__MODULE__, :swap_capabilities)
  end

  @impl true
  def init([]) do
    {
      :ok, 
      %State{
        target_capabilities: [],
        local_capabilities: %{},
        discovered_capabilities: %{}
      }
    }
  end

  @impl true
  def handle_call({:fetch_capabilities, tag}, _from, %State{discovered_capabilities: caps} = state) do
    {:reply, Map.get(caps, tag), state}
  end

  @impl true
  def handle_cast({:add_target_capability_tag, tag}, %State{target_capabilities: target_tags} = state) do
    # Only add unique tagerences
    new_target_tags = [tag | List.delete(target_tags, tag)]
    {:noreply, Map.put(state, :target_capabilities, new_target_tags)}
  end

  @impl true
  def handle_cast({:add_local_capability, {tag, cap}}, %State{local_capabilities: local_caps} = state) do
    new_capabilities = add_capability(tag, cap, local_caps)
    {:noreply, Map.put(state, :local_capabilities, new_capabilities)}
  end

  @impl true
  def handle_cast(:swap_capabilities, %State{local_capabilities: local_caps} = state) do
    [Node.self() | Node.list()]
    |> Enum.each(
        fn node -> 
          GenServer.cast(
            {__MODULE__, node},
            {:swap_capabilities, {Node.self(), local_caps}}
          )
        end
      )
    {:noreply, state}
  end

  @impl true
  def handle_cast({:swap_capabilities, {reply?, friends}}, %State{
    target_capabilities: target_caps,
    local_capabilities: local_caps,
    discovered_capabilities: disco_caps
  } = state) do
    new_disco_caps = capabilities_from_tags(target_caps, friends)
    |> add_capabilities(disco_caps)

    case reply? do
      :noreply -> :ok
      _ ->
        GenServer.cast({__MODULE__, reply?}, {:swap_capabilities, {:noreply, local_caps}})
    end

    {:noreply, Map.put(state, :discovered_capabilities, new_disco_caps)}
  end

  @impl true
  def handle_info(_info, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, _state), do: :ok

  defp add_capabilities([{tag, cap} | tail], caps) do
    add_capabilities(tail, add_capability(tag, cap, caps))
  end

  defp add_capabilities([], caps), do: caps

  defp add_capability(tag, cap, local_capabilities) do
    case Map.get(local_capabilities, cap) do
      nil ->
        Map.put(local_capabilities, tag, [cap])
      capability_list ->
        # Only add unique capabilities
        updated_capability_list = [cap | List.delete(capability_list, cap)]
        Map.put(local_capabilities, tag, updated_capability_list)
    end
  end

  defp capabilities_from_tags(tags, caps) do
    Enum.reduce(
      tags,
      [],
      fn tag, acc ->
        case Map.get(caps, tag) do
          nil -> acc
          cap_list -> (for cap <- cap_list, do: {tag, cap}) ++ acc
        end
      end
    )
  end
end
