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
defmodule SignUp do
  use Penguin.Controller

  
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
