defmodule Rb.Metrics do
  use Task

  def start_link(_), do: Task.start_link(&loop/0)

  defp loop do
    Process.sleep(:timer.seconds(30))
    IO.inspect(collect_metric())
    loop()
  end

  defp collect_metric() do
    [
      memory_usage: :erlang.memory(:total) |> memory_in_mb(),
      process_count: :erlang.system_info(:process_count),
      nodes: Node.list()
    ]
  end

  def memory_in_mb(bytes) do
    kb = bytes / 1024
    mb = kb / 1024
    "#{Float.round(mb, 2)} MB"
  end
end
