defmodule Rb.Router do
  alias Rb.{TableHash, Queue}
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

    # todo validate all user params
    if validate(user) do
      TableHash.save_name(user["nome"])

      id = UUID.uuid4()

      Queue.enqueue(Map.put(user, "id", id))

      # Location: /pessoas/[:id]

      conn
      |> put_resp_content_type("application/json")
      |> put_resp_header("Location", "/pessoas/#{id}")
      |> send_resp(201, "ok")
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(422, "Dados inválidos")
    end
  end

  get "/pessoas/:id" do
    # id = conn.params["id"]

    # {:ok, result} =
    #   Rb.Database.query("SELECT * FROM users WHERE id = $1 LIMIT 1", [
    #     to_binary(id)
    #   ])

    # [user] = format_result(result)

    # response =
    #   Map.update!(user, "id", fn _ -> id end)
    #   |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, "not found")
  end

  get "/contagem-pessoas" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "#{1000}")
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

  def validate(user_map) do
    [
      validate_apelido(user_map["apelido"]),
      validate_nome(user_map["nome"]),
      validate_nascimento(user_map["nascimento"]),
      validate_stack(user_map["stack"])
    ]
    |> Enum.all?(fn elem -> elem end)
  end

  defp validate_apelido(nil), do: false

  defp validate_apelido(apelido) when byte_size(apelido) > 32,
    do: false

  defp validate_apelido(apelido) when not is_binary(apelido),
    do: false

  defp validate_apelido(_apelido), do: true

  defp validate_nome(nil), do: false

  defp validate_nome(nome) when byte_size(nome) > 100,
    do: false

  defp validate_nome(nome) when is_binary(nome) do
    case TableHash.get_name(nome) do
      nil -> true
      _ -> false
    end
  end

  defp validate_nome(_), do: false

  defp validate_nascimento(nil), do: false

  defp validate_nascimento(date) when is_binary(date) do
    Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, date)
  end

  defp validate_nascimento(_), do: false

  defp validate_stack(nil), do: true

  defp validate_stack(stack) when is_list(stack) do
    Enum.all?(stack, &validate_stack_element/1)
  end

  defp validate_stack(_), do: false

  defp validate_stack_element(element) do
    case element do
      e when not is_binary(e) -> false
      e when byte_size(e) > 32 -> false
      _ -> true
    end
  end
end
