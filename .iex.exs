alias Rb.{Database, Queue, TableHash, Router}

user = %{
  "apelido" => "teste",
  "nascimento" => "2000-10-01",
  "nome" => "tes",
  "stack" => ["Elixir", "Java"]
}

users =  List.duplicate(user,1000) |> List.flatten()