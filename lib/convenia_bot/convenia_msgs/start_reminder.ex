defmodule CB.ConveniaBot.ConveniaMsgs.StartReminder do
  alias CB.ConveniaBot.ConveniaMsgs.Helper

  require Logger

  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "admissions.reminder"} = data), do: unquote(__MODULE__).parse(data)
    end
  end

  # def parse(%{"type" => "admission." <> _action} = data) do
  def parse(data) do
    Logger.info(data["type"])

    data
    |> format()
  end

  defp format(data) do
    msg = %{
      blocks:
        [
          %{
            type: "header",
            text: %{
              type: "plain_text",
              text: "Próximas admissões",
              emoji: true
            }
          }
        ] ++ sorted_employees(data["employees"])
    }

    {msg, infra_interna_slack_url()}
  end

  defp sorted_employees(employees) do
    employees
    |> Enum.sort_by(fn e -> e["hiring_date"] end)
    |> Enum.map(&format_start/1)
    |> Enum.reduce(%{}, &join_phrases/2)
    |> Enum.reverse()
    |> join_blocks([])
  end

  defp format_start(employee) do
    {
      employee["hiring_date"],
      "*#{Helper.proper_name(employee)}*\n#{employee["job"]["name"]} - #{employee["cost_center"]["name"]} - #{
        Helper.supervisor(employee)
      }\n
Cel: `#{Helper.format_phone(employee["cellphone"])}` Email: `#{
        employee["email"] || employee["alternative_email"]
      }`\n
#{Helper.format_address(employee["address"])}"
    }
  end

  defp join_phrases({date, phrase}, acc) do
    case Map.fetch(acc, date) do
      :error ->
        Map.put(acc, date, "*#{format_date(date)}*\n#{phrase}")

      {:ok, value} ->
        Map.put(acc, date, Enum.join([value, phrase], "\n\n"))
    end
  end

  defp join_blocks([], acc), do: acc

  defp join_blocks([{_k, phrase} | t], acc) do
    i =
      case Enum.count(t) do
        0 ->
          [
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: phrase
              }
            }
          ]

        _ ->
          [
            %{
              type: "divider"
            },
            %{
              type: "section",
              text: %{
                type: "mrkdwn",
                text: phrase
              }
            }
          ]
      end

    join_blocks(t, i ++ acc)
  end

  defp format_date(date) do
    date
  end

  defp infra_interna_slack_url(),
    do: Application.fetch_env!(:convenia_bot, :infra_interna_slack_url)
end
