defmodule CB.ConveniaBot do
  require Logger

  def process(data) do
    Logger.info("Starting process...")

    d = CB.ConveniaBot.ConveniaMsgs.parse(data)

    Logger.info("Process ended.")
    d
  end

  # defp enrich({:error, a}), do: {:error, a, []}

  # defp format({:error, %{data: %{"type" => type}}, _}) do
  #   {%{text: "Bad request: #{type}"}, ""}
  # end

  # defp sort(data) do
  #   Logger.info(["Bad sort", inspect(data)])
  #   {:error, %{error: "Couldn't figure out Convenia is talking about", data: data}}
  # end
end
