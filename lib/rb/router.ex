defmodule Rb.Router do
  alias Rb.{Apelidos, Queue}
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

    case validate(user) do
      :ok ->
        id = UUID.uuid4()
        Apelidos.save(user["apelido"])
        Queue.enqueue(Map.put(user, "id", id))

        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("Location", "/pessoas/#{id}")
        |> send_resp(201, "ok")

      {status, error_message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, Jason.encode!(%{"error" => error_message}))
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

  get "/pessoas" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "")
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
  # defp format_result(%Postgrex.Result{columns: columns, rows: rows}) do
  #   rows
  #   |> Enum.map(fn row ->
  #     Enum.zip(columns, row)
  #     |> Enum.into(%{})
  #   end)
  # end

  def validate(user_map) do
    with :ok <- validate_apelido(user_map["apelido"]),
         :ok <- validate_nome(user_map["nome"]),
         :ok <- validate_nascimento(user_map["nascimento"]),
         :ok <- validate_stack(user_map["stack"]) do
      :ok
    else
      error -> error
    end
  end

  defp validate_apelido(nil), do: {:unprocessable_entity, "Apelido não pode ser nulo"}

  defp validate_apelido(apelido) when not is_binary(apelido),
    do: {:bad_request, "Apelido deve ser uma string"}

  defp validate_apelido(apelido) when byte_size(apelido) > 32,
    do: {:unprocessable_entity, "Apelido é muito longo"}

  defp validate_apelido(apelido) when is_binary(apelido) do
    case Apelidos.get(apelido) do
      false -> :ok
      _ -> {:unprocessable_entity, "Apelido já existe"}
    end
  end

  defp validate_nome(nil), do: {:unprocessable_entity, "Nome não pode ser nulo"}

  defp validate_nome(nome) when not is_binary(nome),
    do: {:bad_request, "Nome deve ser uma string"}

  defp validate_nome(nome) when byte_size(nome) > 100,
    do: {:unprocessable_entity, "Nome é muito longo"}

  defp validate_nome(nome) when is_binary(nome), do: :ok

  defp validate_nascimento(nil), do: {:unprocessable_entity, "Nascimento não pode ser nulo"}

  defp validate_nascimento(date) when is_binary(date) do
    case Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, date) do
      true -> :ok
      _ -> {:Bad_request, "Nascimento inválido"}
    end
  end

  defp validate_nascimento(_), do: {:Bad_request, "Nascimento inválido"}

  defp validate_stack(nil), do: :ok

  defp validate_stack(stack) when not is_list(stack),
    do: {:bad_request, "Stack deve ser uma lista"}

  defp validate_stack(stack) do
    case Enum.all?(stack, &validate_stack_element/1) do
      true -> :ok
      _ -> {:bad_request, "Stack inválido"}
    end
  end

  defp validate_stack_element(element) do
    case element do
      e when not is_binary(e) -> false
      e when byte_size(e) > 32 -> false
      _ -> true
    end
  end
end
