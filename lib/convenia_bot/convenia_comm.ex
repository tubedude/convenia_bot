defmodule CB.ConveniaComm do
  require Logger

  @convenia_base_url "https://public-api.convenia.com.br/api/v3/"
  defp convenia_token(), do: Application.fetch_env!(:convenia_bot, :convenia_token)

  def fetch_employee_info(id), do: fetch_employee_info(id, [], 0)
  def fetch_employee_info(id, opts), do: fetch_employee_info(id, opts, 0)
  def fetch_employee_info(id, opts, retries) when is_binary(id) do
    url = @convenia_base_url <> "employees/" <> id
    Logger.debug("Fetching for: #{url}")

    case HTTPoison.get(url, [{:token, convenia_token()}], opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.debug("Fetch Info: returned 200")

        case Jason.decode(body) do
          {:ok, json} ->
            {:ok, json["data"]}

          {:error, e} ->
            # "Error decoding Response"
            Logger.info(inspect(e))
            {:error, e}
        end

      {:ok, %HTTPoison.Response{status_code: 429, body: _body}} ->
        Logger.info("Fetch Info: returned 429")
        cooldown = 10000 * round(:math.pow(2, retries + 1))
        Logger.debug("Too many attempts: cooling down for #{cooldown}.")
        :timer.sleep(cooldown)
        fetch_employee_info(id, opts, retries + 1)

      {:ok, %HTTPoison.Response{status_code: 401, body: _body}} ->
        Logger.info("Fetch Info: returned 401")
        {:error, "Enrichment returned: 401"}

      {:ok, %HTTPoison.Response{status_code: status_code, body: _body}} ->
        {:error, "Enrichment returned: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason} = resp} ->
        Logger.warn(resp)
        {:error, "Enrichment returned: #{reason}"}
    end
  end

  def fetch_employee_info!(e) do
    case fetch_employee_info(e) do
      {:ok, employee} -> employee
      err -> err
    end
  end

  defp fetch_employees() do
    url = @convenia_base_url <> "employees"
    Logger.debug("Fetching for: #{url}")

    case HTTPoison.get(url, [{:token, convenia_token()}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.debug("Fetch Info: returned 200")
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: 429, body: _body}} ->
        Logger.info("Fetch Info: returned 429")
        :timer.sleep(60000)
        fetch_employees()

      {:error, %HTTPoison.Error{reason: _reason} = error} = resp->
        Logger.warn(error)
        resp
    end
  end

  def fetch_employees!() do
    case fetch_employees() do
      {:ok, employees} ->
        employees["data"]
        |> take_if_dev()

      {_, err} ->
        Logger.debug(err)
        []
    end
  end

  defp take_if_dev(data) do
    if unquote(Mix.env() == :dev) do
      data
      |> Enum.take(10)
    else
      data
    end
  end
end
