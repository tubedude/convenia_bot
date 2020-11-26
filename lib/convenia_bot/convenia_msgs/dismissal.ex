defmodule CB.ConveniaBot.ConveniaMsgs.Dismissal do
  alias CB.ConveniaBot.ConveniaMsgs.Helper

  require Logger

  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "dismissal." <> _action} = data), do: unquote(__MODULE__).parse(data)
    end
  end

  # defp parse(%{"type" => "dismissal." <> _action} = data) do
  def parse(data) do
    data
    |> sort()
    |> Helper.standard_enrich()
    |> format()
  end

  defp sort(%{"type" => "dismissal." <> _action} = data) do
    Logger.info(data["type"])

    {
      :dismissal,
      Map.put(data, :employee, data["employee"])
    }
  end

  defp format({:dismissal, data, info}) do
    msg = %{
      blocks: [
        %{
          type: "header",
          text: %{
            type: "plain_text",
            text: "Desligamento de #{Helper.proper_name(info)}",
            emoji: true
          }
        },
        %{
          type: "section",
          text: %{
            type: "mrkdwn",
            text:
              "#{info["name"]} sairá da Quanto por #{data["dismissal_type"]["name"]}.\n Aviso feito em #{
                data["termination_notice_date"]
              } e último dia em #{data["dismissal_date"]}."
          }
        },
        %{
          type: "section",
          text: %{
            type: "mrkdwn",
            text: "Mais informações:"
          },
          accessory: %{
            type: "button",
            text: %{
              type: "plain_text",
              text: "Convênia",
              emoji: true
            },
            value: "click_me_123",
            url:
              "https://app.convenia.com.br/colaboradores/#{info["id"]}/detalhes/historicos/atualizacoes",
            action_id: "button-action"
          }
        }
      ]
    }

    {msg, Helper.slack_url()}
  end
end
