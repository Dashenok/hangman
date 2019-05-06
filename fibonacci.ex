defmodule Fibonacci do

  def fib(n) do
    Cache.run(fn cache -> cached_fib(cache, n) end)
  end

  def cached_fib(cache, n) do
    Cache.lookup(cache, n, fn -> cached_fib(cache, n-2) + cached_fib(cache, n-1) end)
  end

end

defmodule Cache do
  def run(body) do
    {:ok, pid } = Agent.start_link(fn -> %{0 => 0, 1 => 1} end)
    result = body.(pid)
    Agent.stop(pid)
    result
  end

  def lookup(cache, n, if_not_find) do
    Agent.get(cache, fn map -> map[n] end)
    |> complete_if_not_find(cache, n, if_not_find)
  end

  defp complete_if_not_find(nil, cache, n, if_not_find) do
    if_not_find.()
    |> set(cache, n)
  end

  defp complete_if_not_find(value, _cache, _n, _if_not_find) do
    value
  end

  defp set(value, cache, n) do
    Agent.get_and_update(cache, fn map -> {value, Map.put(map, n, value)} end)
  end
end
