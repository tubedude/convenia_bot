defmodule CB.ExternalComm do
  require Logger

  def info(), do: {:ok, %{name: "Slack"}}

  def post(data) do
    Logger.info("Posting to Slack...")
    {payload, url, header} = CB.process(data)

    case HTTPoison.post(url, Jason.encode!(payload), header) do
      {:ok, %{status_code: 200}} ->
        {:ok,  %{status_code: 200, payload: payload}}

      {:ok, %{status_code: status_code}} ->
        {:error, %{status_code: status_code, payload: payload}}

      {:error, resp} ->
        Logger.debug(inspect(resp))
        {:error, %{reason: resp.reason, text: "API returned with error."}}
    end
  end
end
