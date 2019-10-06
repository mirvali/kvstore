#Этот модуль должен реализовать механизмы CRUD для хранения данных. Если одного модуля будет мало, то допускается создание модулей с префиксом "Storage" в названии.
defmodule KVstore.KVStorage do

  use GenServer
  import :os

  @mytable :kvtable

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    :dets.open_file(@mytable, [type: :set])
    timer = Process.send_after(self(), :cleanup, 3000)
    {:ok, %{timer: timer}}
  end

  def handle_info(:cleanup, _state) do
    time = system_time(:seconds)
    keys = :dets.select(@mytable, [{{:"$1", :_, :"$3"}, [{:<, :"$3", time}], [:"$1"]}])
    Enum.each(keys, fn key -> :dets.delete(@mytable, key) end)
    :dets.sync(@mytable)

    timer = Process.send_after(self(), :cleanup, 3000)
    {:noreply, %{timer: timer}}
  end

  def handle_info(_, state) do
    {:ok, state}
  end
  def create(key, value, ttl) do
    timeout = system_time(:seconds) + ttl
    :dets.insert(@mytable, {key, value, timeout})
    :dets.sync(@mytable)
  end
  def find(key) do
    case :dets.lookup(@mytable, key) |> List.first() do
      {_, value, _} ->
          value
      _ -> :not_found
    end
  end
  def del(key) do
    try do
      :dets.delete(@mytable, key)
      :dets.sync(@mytable)
    rescue
      _-> :delete_error
    else
      _-> :deleted
    end
  end
end
