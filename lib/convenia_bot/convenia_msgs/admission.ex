defmodule CB.ConveniaMsgs.Admission do
  alias CB.ConveniaMsgs.Helper

  require Logger

  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "admission." <> _action} = data), do: unquote(__MODULE__).parse(data)
    end
  end

  # def parse(%{"type" => "admission." <> _action} = data) do
  def parse(data) do
    data
    |> sort()
    |> Helper.standard_enrich()
    |> generate_pulse()
    |> format()
  end

  defp sort(data) do
    # defp sort(%{"type" => "admission." <> _action} = data) do
    Logger.info("Using #{__MODULE__}")

    {:admission,
     %{
       type: data["type"],
       status_name: data["status_name"],
       employee: data["employee"]
     }}
  end

  # defp format({:admission, _data, info}) do
  defp format({_type, _data, info}) do
    msg = %{
      blocks: [
        %{
          type: "header",
          text: %{
            type: "plain_text",
            text: "Nova contratação: #{info["name"]} #{info["last_name"]}",
            emoji: true
          }
        },
        %{
          type: "section",
          text: %{
            type: "mrkdwn",
            text:
              "#{info["name"]} começará em #{info["hiring_date"]} como #{info["job"]["name"]}, #{
                Helper.supervisor(info)
              }.\nTrabalhará de #{info["address"]["city"]} recebendo R$#{info["salary"]}."
          },
          accessory: %{
            type: "image",
            image_url: "https://fontmeme.com/images/name-tag-generator.png",
            alt_text: "Hello Awesome"
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
            value: "Goes to Convenia",
            url: "https://app.convenia.com.br/colaboradores/#{info["id"]}/detalhes/pessoal/",
            action_id: "button-action"
          }
        }
      ]
    }

    {msg, Helper.slack_url()}
  end

  defp generate_pulse({_id, _body, employee} = data) do
    pulse_data = %{
      "type" => "admission.pulses",
      "status_name" => "GeneratePulse",
      "employee" => employee
    }
# CB.ExternalComm.post(data)
    Task.start_link(CB.ExternalComm, :post, [pulse_data] )

    data
  end

end
