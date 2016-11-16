defmodule Conduit.Plug.LogOutgoing do
  use Conduit.Plug.Builder
  require Logger

  def init(opts) do
    Keyword.get(opts, :log, :info)
  end

  def call(message, level) do
    start = System.monotonic_time()

    try do
      Logger.log(level, fn ->
        ["Sending message to ", message.destination]
      end)

      super(message, level)
    after
      Logger.log(level, fn ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :micro_seconds)

        ["Sent message to ", message.destination, " in ", formatted_diff(diff)]
      end)
    end
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string, "ms"]
  defp formatted_diff(diff), do: [diff |> Integer.to_string, "µs"]
end
