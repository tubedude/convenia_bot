defmodule CB.ConveniaMsgs.BirthdayReminder do
  alias CB.ConveniaMsgs.Helper

  require Logger

  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "birthday." <> _action} = data), do: unquote(__MODULE__).parse(data)
    end
  end

  # def parse(%{"type" => "admission." <> _action} = data) do
  def parse(data) do
    Logger.info(data["type"])

    data
    |> format()
  end

  defp format(data) do
    names =
      data["employees"]
      |> Enum.map(&Helper.proper_name/1)
      |> Enum.map(fn e -> "`#{e}`" end)
      |> Enum.join(", ")

    verb =
      case Enum.count(data["employees"]) do
        1 -> "faz"
        _ -> "fazem"
      end

    msg = %{
      blocks: [
        %{
          type: "header",
          text: %{
            type: "plain_text",
            text: "Hoje tem aniversário :tada:",
            emoji: true
          }
        },
        %{
          type: "section",
          text: %{
            type: "mrkdwn",
            text: "Hoje #{names} #{verb} aniversário!"
          }
        }
      ]
    }

    {msg, comms_slack_url(), []}
  end

  defp comms_slack_url(),
  do: Application.fetch_env!(:convenia_bot, :comms_slack_url)

end
