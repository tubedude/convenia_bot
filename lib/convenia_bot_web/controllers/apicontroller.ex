defmodule CBWeb.ApiController do
  use CBWeb, :controller

  require Logger

  @secret_user Application.fetch_env!(:convenia_bot, :secret_user)
  @secret_pass Application.fetch_env!(:convenia_bot, :secret_pass)
  @version Mix.Project.config()[:version]

  def check(conn, _param), do: json(conn, %{ok: @version})

  def force_admissions_check(conn, _params) do
    Logger.info("Forcing addmissions check")
    json(conn, CB.Employees.check_admissions())
  end

  def incoming(conn, params) do
    Logger.info(inspect(params))

    case params do
      %{
        "secret_user" => @secret_user(),
        "secret_pass" => @secret_pass()
      } = data ->
        conn
        |> json(CB.ExternalComm.post(data))

      _error ->
        conn
        |> put_status(401)
        |> json(%{:error => "error"})
    end
  end

  def toggle_employee(conn, _params) do
    conn
  end
end
