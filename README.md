# Penguin

### In router

```elixir
defmodule MyApp.Router do
  use Penguin

  defroute :post, "/sign-up", MyApp.Controller.SignUp
end
```

### In controller
```elixir
defmodule DoSomething do
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
```

or without validation but with user status check
```elixir
defmodule DoSomething do
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
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `penguin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:penguin, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/penguin](https://hexdocs.pm/penguin).
