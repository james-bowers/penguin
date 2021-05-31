defmodule PenguinTest do
  use ExUnit.Case
  use Plug.Test

  doctest Penguin

  test "greets the world" do
    assert Penguin.hello() == :world
  end

  defmodule SubjectController do
    use Penguin.Controller

    embedded_schema do
      field(:title, :string)
    end

    @impl true
    def validation_changeset(%{query_params: params}) do
      %__MODULE__{}
      |> Ecto.Changeset.cast(params, [:title])
      |> Ecto.Changeset.validate_required([:title])
    end

    @impl true
    def handle(conn, %PenguinTest.SubjectController{title: _title}, _user_state) do
      send_resp(conn, 200, "hello world")
    end

    @impl true
    def valid_user_states, do: :public
  end

  :signed_in

  defmodule SubjectProtectedController do
    use Penguin.Controller

    @impl true
    def validate(_input) do
      {:ok, %{}}
    end

    @impl true
    def handle(conn, _input, _user_state) do
      send_resp(conn, 200, "OK")
    end

    @impl true
    def valid_user_states, do: [:signed_in]
  end

  defmodule SubjectRouter do
    use Penguin.RouteMaster
    plug(:fetch_query_params)
    plug(:match)
    plug(:dispatch)

    defroute(:get, "/", SubjectController)

    defroute(:get, "/private", SubjectProtectedController)
  end

  describe "integration test" do
    test "valid input, public endpoint" do
      conn = conn(:get, "/?title=hi")
      assert {200, _resp_headers, "hello world"} = SubjectRouter.call(conn, []) |> sent_resp()
    end

    test "invalid input, public endpoint" do
      conn = conn(:get, "/")

      assert {400, _resp_headers, ~s({"title":["can't be blank"]})} =
               SubjectRouter.call(conn, []) |> sent_resp()
    end

    test "valid input, valid user status" do
      conn = conn(:get, "/private") |> Plug.Conn.assign(:user_status, :signed_in)

      assert {200, _resp_headers, ~s(OK)} = SubjectRouter.call(conn, []) |> sent_resp()
    end

    test "valid input, invalid user status" do
      conn = conn(:get, "/private") |> Plug.Conn.assign(:user_status, :anonymous)

      assert {403, _resp_headers, ~s({"error_message": "Permission denied."})} =
               SubjectRouter.call(conn, []) |> sent_resp()
    end
  end
end
