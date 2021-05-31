defmodule Penguin.RouteMaster do
  defmacro __using__(_opts) do
    quote do
      use Plug.Router
      import Penguin.RouteMaster
    end
  end

  defmacro defroute(method, path_matcher, controller) do
    quote do
      match unquote(path_matcher), via: unquote(method) do
        conn = var!(conn)

        untrusted_input =
          Map.take(conn, [:req_headers, :body_params, :path_params, :query_params])

        with {:ok, :valid_user_state, actual_user_state} <-
               Penguin.RouteMaster.validate_user_state(
                 unquote(controller).valid_user_states(),
                 Map.get(conn.assigns, :user_status)
               ),
             {:validation, {:ok, validated_params}} <-
               {:validation, unquote(controller).validate(untrusted_input)} do
          unquote(controller).handle(conn, validated_params, actual_user_state)
        else
          {:validation, {:error, reasons}} ->
            unquote(controller).on_failed_validation(conn, reasons)

          {:error, :invalid_user_state, found_user_state} ->
            unquote(controller).on_invalid_user_state(conn, found_user_state)
        end
      end
    end
  end

  def validate_user_state(:public, actual_user_state) do
    {:ok, :valid_user_state, actual_user_state}
  end

  def validate_user_state(valid_states, actual_user_state) do
    if actual_user_state in valid_states do
      {:ok, :valid_user_state, actual_user_state}
    else
      {:error, :invalid_user_state, actual_user_state}
    end
  end
end
