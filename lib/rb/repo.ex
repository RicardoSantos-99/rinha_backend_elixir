defmodule Repo do
  use Ecto.Repo,
    otp_app: :rb,
    adapter: Ecto.Adapters.Postgres

  def search_pessoas_by_term(term) when is_binary(term) do
    sql = """
    select id::varchar, apelido, nome, nascimento, stack
    from users where
    (apelido || ' ' || nome || ' ' || stack) ilike $1
    limit 50
    """

    query(sql, ["%" <> term <> "%"])
  end
end
