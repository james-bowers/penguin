defmodule Penguin.ControllerTest do
  use ExUnit.Case
  use Plug.Test

  defmodule SubjectController do
    use Penguin.Controller

    embedded_schema do
      field(:title, :string)
    end

    def validation_changeset(params) do
      %__MODULE__{}
      |> Ecto.Changeset.cast(params, [:title])
      |> Ecto.Changeset.validate_required([:title])
    end

    def handle(conn, _input, _user_state) do
      send_resp(conn, 200, "hello world")
    end

    def valid_user_states, do: :public
  end

  test "validates an input, when is valid" do
    assert {:ok,
            %SubjectController{
              title: "Hey you"
            }} == SubjectController.validate(%{title: "Hey you"})
  end

  test "validates an input, when is invalid" do
    assert {:error, %Ecto.Changeset{}} = SubjectController.validate(%{title: ""})
  end

  test "on_failed_validation/2" do
    conn = conn(:get, "/foo?bar=10")

    {:error, failed_changeset} = SubjectController.validate(%{title: ""})

    assert {400, _headers, resp_body} =
             SubjectController.on_failed_validation(conn, failed_changeset) |> sent_resp()

    assert %{"title" => ["can't be blank"]} == Jason.decode!(resp_body)
  end

  test "on_invalid_user_state/2" do
    conn = conn(:get, "/foo?bar=10")

    assert {403, _headers, resp_body} =
             SubjectController.on_invalid_user_state(conn, :anonymous) |> sent_resp()

    assert %{"error_message" => "Permission denied."} == Jason.decode!(resp_body)
  end
end
