defmodule Rb.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/pessoas" do
    user = conn.params

    # users = Postgrex.query(pid, "SELECT nome FROM pessoas limit 1", [])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(user))
  end

  get "/pessoas/:id" do
    id = conn.params["id"]

    {:ok, result} =
      Rb.Database.query("SELECT * FROM users WHERE id = $1 LIMIT 1", [
        to_binary(id)
      ])

    [user] = format_result(result)

    response =
      Map.update!(user, "id", fn _ -> id end)
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end

  def to_binary(uuid_string) when is_binary(uuid_string) do
    parts = uuid_string |> String.split("-", parts: 5)
    <<String.to_integer(Enum.join(parts), 16)::128>>
  end

  # Função auxiliar para formatar o resultado do Postgrex
  defp format_result(%Postgrex.Result{columns: columns, rows: rows}) do
    rows
    |> Enum.map(fn row ->
      Enum.zip(columns, row)
      |> Enum.into(%{})
    end)
  end
end
