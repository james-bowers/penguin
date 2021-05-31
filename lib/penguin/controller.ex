defmodule Penguin.Controller do
  @type validated_params :: any()
  @type user_state :: atom()
  @type input_for_validation :: %{
          req_headers: List.t(),
          body: any(),
          path_params: Map.t(),
          query_params: Map.t() | List.t()
        }
  @type validation_errors :: Ecto.Changeset.t() | any()

  @callback handle(Plug.Conn.t(), validated_params, user_state) :: Plug.Conn.t()
  @callback validation_changeset(input_for_validation) :: Ecto.Changeset.t()
  @callback on_failed_validation(Plug.Conn.t(), validation_errors) :: Plug.Conn.t()
  @callback on_invalid_user_state(Plug.Conn.t(), atom()) :: Plug.Conn.t()
  @callback valid_user_states() :: [atom()]
  @callback validate(input_for_validation) :: {:ok, any()} | {:error, any()}

  @optional_callbacks [
    validate: 1,
    validation_changeset: 1,
    on_failed_validation: 2,
    on_invalid_user_state: 2
  ]

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Ecto.Schema

      @validation_module Keyword.get(opts, :validation_module, __MODULE__)

      @behaviour Penguin.Controller

      @impl true
      def validate(untrusted_input) do
        @validation_module.validation_changeset(untrusted_input)
        |> Ecto.Changeset.apply_action(:create)
      end

      @impl true
      def on_invalid_user_state(conn, _actual_user_state) do
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(403, ~s({"error_message": "Permission denied."}))
      end

      @impl true
      def on_failed_validation(conn, %Ecto.Changeset{} = error_changeset) do
        error_mappings =
          Ecto.Changeset.traverse_errors(error_changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        response_body = Jason.encode!(error_mappings)

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, response_body)
      end

      @impl true
      def on_failed_validation(conn, _errors) do
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(400, Jason.encode!(%{error_message: "Validation failed."}))
      end

      defoverridable validate: 1, on_failed_validation: 2, on_invalid_user_state: 2
    end
  end
end
