defmodule CB.ConveniaMsgs.Helper do
  require Logger
  alias CB.Employees

  def proper_name(employee) do
    "#{capitalize(employee["name"])} #{capitalize(employee["last_name"])}"
  end

  defp capitalize(name) do
    name
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def format_address(address) do
    "#{address["address"]}, #{address["number"]} #{address["complement"]}
 - #{address["zipcode"]} - #{address["city"]}, #{address["state"]}"
  end

  def format_phone(nil), do: ""
  def format_phone(phone_string), do: format_phone(phone_string, "(##) #####-####")

  def format_phone(phone_string, pattern) do
    case String.match?(pattern, ~r/\#/) do
      false ->
        pattern

      true ->
        [d | r] = String.to_charlist(phone_string)
        p = String.replace(pattern, "#", to_string([d]), global: false)
        format_phone(to_string(r), p)
    end
  end

  def slack_url(), do: Application.fetch_env!(:convenia_bot, :slack_url)

  def standard_enrich({type, %{employee: employee} = data}) do
    Logger.debug(inspect(data))
    ee = Employees.find(employee["id"])
    {type, Map.put(data, :body, ee), ee}
  end

  def supervisor(info) do
    case info["supervisor"]["nome"] do
      nil -> "sem supervisor definido"
      gestor -> "na equipe gerida por #{gestor} #{info["supervisor"]["last_name"]}"
    end
  end
end
