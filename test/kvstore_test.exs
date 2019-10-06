defmodule KVstore.KVRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias KVstore.KVRouter
  alias KVstore.KVStorage
  require Logger

  @opts KVRouter.init([])

  KVStorage.create("name", "John", 300)


  Logger.debug("start GET")
  test "return error if unknown key" do
    conn = conn(:get, "/xxx") |> KVRouter.call(@opts)
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Record not found"
  end

  test "return value by key if exist" do
    conn = conn(:get, "/name") |> KVRouter.call(@opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "John"
  end

  Logger.debug("start POST")
  test "post ttl param exception" do
    conn = conn(:post, "/", "key=name&value=bla&ttl=")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "The parameter ttl is not integer"
  end

  test "post key param exception" do
    conn = conn(:post, "/", "key=&value=bla&ttl=300")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Error parameter key"
  end

  test "post value param exception" do
    conn = conn(:post, "/", "key=age&value=&ttl=123")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Error parameter value"
  end

  test "save/create key-value " do
    conn = conn(:post, "/", "key=age&value=99&ttl=300")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Successfully"
  end

  Logger.debug("start PUT")
  test "update record by key" do
    conn = conn(:put, "/name","value=John&ttl=300")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Successfully"
  end

  test "put ttl param exception" do
    conn = conn(:put, "/", "key=name&value=John&ttl=")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "The parameter ttl is not integer"
  end

  test "put value param exception" do
    conn = conn(:put, "/", "key=namevalue=&ttl=123")
    |> put_req_header("content-type", "application/x-www-form-urlencoded")
    |> KVRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 422
    assert conn.resp_body == "Error parameter value"
  end

  Logger.debug("start DELETE")

  test "unknown key exception" do
    conn = conn(:delete, "/xxx") |> KVRouter.call(@opts)
    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Record not found"
  end

  test "success delete key-value" do
    conn = conn(:delete, "/name") |> KVRouter.call(@opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Deleted"
  end

end
