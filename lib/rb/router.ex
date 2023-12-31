defmodule Rb.Router do
  alias Rb.{Apelidos, Queue, UsersCache}
  alias Ecto.UUID
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/pessoas" do
    user =
      conn.body_params
      |> Enum.into(%{}, fn {key, value} ->
        {String.to_atom(key), value}
      end)

    case validate(user) do
      :ok ->
        id = UUID.generate()
        Apelidos.save(user.apelido)

        user
        |> Map.update(:id, id, fn _ -> id end)
        |> UsersCache.insert()

        user
        |> format_user_to_save(id)
        |> Queue.enqueue()

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

  get "/pessoas" do
    conn = fetch_query_params(conn)

    case conn.query_params do
      %{"t" => term} ->
        {:ok, users} = Repo.search_pessoas_by_term(term)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(format_result(users)))

      _ ->
        send_resp(conn, 400, "")
    end
  end

  get "/pessoas/:id" do
    id = conn.params["id"]

    case UsersCache.get(id) do
      nil ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, "not found")

      user ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(user))
    end
  end

  get "/contagem-pessoas" do
    sql = """
    SELECT COUNT(id) FROM users
    """

    {:ok, %Postgrex.Result{rows: [[rows]]}} = Ecto.Adapters.SQL.query(Repo, sql, [])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "#{rows}")
  end

  defp binary_uuid(str) do
    UUID.dump(str) |> then(fn {:ok, uuid} -> uuid end)
  end

  defp format_user_to_save(user, id) do
    Map.put(user, :id, binary_uuid(id))
    |> Map.update!(:nascimento, fn data -> Date.from_iso8601!(data) end)
  end

  defp format_result(%Postgrex.Result{rows: []}), do: []

  defp format_result(%Postgrex.Result{columns: columns, rows: rows}) do
    cols = Enum.map(columns, &String.to_atom/1)

    Enum.map(rows, &(Enum.zip(cols, &1) |> Map.new()))
    |> Enum.map(&Map.replace(&1, :stack, string_to_list(&1.stack)))
  end

  defp string_to_list(""), do: []
  defp string_to_list(string), do: String.split(string, " ")

  defp validate(user_map) do
    with :ok <- validate_apelido(user_map.apelido),
         :ok <- validate_nome(user_map.nome),
         :ok <- validate_nascimento(user_map.nascimento),
         :ok <- validate_stack(user_map.stack) do
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
    case match?({:ok, _}, Date.from_iso8601(date)) do
      true -> :ok
      _ -> {:bad_request, "Nascimento inválido"}
    end
  end

  defp validate_nascimento(_), do: {:bad_request, "Nascimento inválido"}

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
