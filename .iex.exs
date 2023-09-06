# alias Rb.{Queue, Apelidos, Router, Worker, UsersCache}
# alias Ecto.Adapters.SQL
# alias Ecto.UUID

# user = %{
#   "id" => UUID.generate(),
#   "apelido" => "tlçasdjfklasdjfsdklajfte",
#   "nascimento" => Date.from_iso8601!("2000-10-01"),
#   "nome" => "dsjfsdlçakfjlsdkçajtes",
#   "stack" => ["Elixir", "Java"]
# }

# sql = """
# INSERT INTO users (stack, id, nascimento, apelido, nome)
# VALUES ($1, $2, $3, $4, $5)
# """

# values = [
#   Map.get(user, "stack"),
#   Map.get(user, "id"),
#   Map.get(user, "nascimento"),
#   Map.get(user, "apelido"),
#   Map.get(user, "nome")
# ]

# gen = fn ->
#   [
#     ["Elixir", "Java"],
#     UUID.generate() |> UUID.dump() |> then(fn {:ok, uuid} -> uuid end),
#     Date.from_iso8601!("2000-10-01"),
#     "dsjfsdlçakfjlsdkçajtes",
#     "tlçasdjfklasdjfsdklajfte"
#   ]
# end

# users = List.duplicate(user, 10000) |> List.flatten()

# Enum.map(1..10, fn _ -> Ecto.Adapters.SQL.query(Repo, sql, gen.()) end)

# Task.async_stream(1..10, fn _ -> SQL.query(Repo, sql, gen.()) end, ordered: false, max_concurrency: 10)
# |> Enum.to_list()
