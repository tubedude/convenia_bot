defmodule CB.ConveniaMsgs.Vacations do
  require Logger

  alias CB.ConveniaMsgs.Helper

  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "vacation." <> _action} = data), do: unquote(__MODULE__).parse(data)
    end
  end

  def parse(data) do
    data
    |> sort()
    |> Helper.standard_enrich()
    |> format()
  end

  # def sort(%{"type" => "vacation." <> _action} = data) do
  def sort(data) do
    Logger.info(data["type"])

    {
      :vacations,
      Map.put(data, :employee, data["employee"])
    }
  end

  defp format({:vacations, data, info}) do
    msg = %{
      blocks: [
        %{
          type: "header",
          text: %{
            type: "plain_text",
            text: "Pedido de férias: #{Helper.proper_name(info)}",
            emoji: true
          }
        },
        %{
          type: "section",
          text: %{
            type: "mrkdwn",
            text:
              "#{info["name"]} pediu *#{data["days"]}* dias de férias começando em #{
                data["start_date"]
              }."
          },
          accessory: %{
            type: "image",
            image_url:
              "https://image.shutterstock.com/image-photo/coconut-sunglasses-strawhat-tropical-beach-600w-1751794199.jpg",
            alt_text: "Coconut"
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
              "https://app.convenia.com.br/colaboradores/#{info["id"]}/detalhes/profissional/ferias",
            action_id: "button-action"
          }
        }
      ]
    }

    {msg, Helper.slack_url()}
  end
end
