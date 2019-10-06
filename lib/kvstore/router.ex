#Для веб сервера нужен маршрутизатор, место ему именно тут.
defmodule KVstore.KVRouter do

  use Plug.Router
  require Logger
  alias KVstore.KVStorage

  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :match
  plug :dispatch


  get "/:key" do
    case KVStorage.find(key) do
      :not_found -> send_resp(conn, 404, "Record not found")
      value -> send_resp(conn, 200, value)
    end
  end

  post "/" do
    crud(conn.params, conn)
  end

  put "/:key" do
    Map.put(conn.params, "key", key)
    crud(conn.params, conn)
  end

  delete "/:key" do
    case KVStorage.find(key) do
      :not_found -> send_resp(conn, 404, "Record not found")
      _value ->
            case KVStorage.del(key) do
               :delete_error -> send_resp(conn, 404, "Delete error")
               :deleted -> send_resp(conn, 200, "Deleted")
            end
    end
  end

  defp crud(%{"key" => ""}, conn), do: send_resp(conn, 422, "Error parameter key")
  defp crud(%{"value" => ""}, conn), do: send_resp(conn, 422, "Error parameter value")

  defp crud(%{"key" => key, "value" => value, "ttl" => ttl}, conn) do
    case Integer.parse(ttl) do
      {ttl_num,_} ->
          KVStorage.create(key, value, ttl_num)
          send_resp(conn, 200, "Successfully")
      _-> send_resp(conn, 422, "The parameter ttl is not integer")
    end
  end

  match _ do
    send_resp(conn, 404, "404 error not found!")
  end

end
