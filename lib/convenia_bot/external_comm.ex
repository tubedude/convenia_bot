defmodule CB.ConveniaBot.ExternalComm do
  require Logger

  def info(), do: {:ok, %{name: "Slack"}}

  def post(data) do
    Logger.info("Posting to Slack...")
    {payload, channel} = CB.ConveniaBot.process(data)

    case HTTPoison.post(channel, Jason.encode!(payload)) do
      {:ok, %{status_code: 200}} ->
        %{ok: %{slack_status_code: 200, payload: payload}}

      {:ok, %{status_code: status_code}} ->
        %{error: %{slack_status_code: status_code, payload: payload}}

      {:error, resp} ->
        Logger.debug(inspect(resp))
        %{error: %{reason: resp.reason, text: "Slack API returned with error."}}
    end
  end
end
