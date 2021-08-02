defmodule CB.ConveniaMsgs.AdmissionPulses do
  alias CB.ConveniaMsgs.Helper

  require Logger

  defmacro __using__(_opts) do
    quote do
      def parse(%{"type" => "admission.pulses"} = data), do: unquote(__MODULE__).parse(data)
    end
  end

  # def parse(%{"type" => "admission." <> _action} = data) do
  def parse(data) do
    data
    |> sort()
    |> format()
  end

  defp sort(data) do
    # defp sort(%{"type" => "admission." <> _action} = data) do
    Logger.info("Using #{__MODULE__}")

    {:admission,
     %{
       type: data["type"],
       status_name: data["status_name"]
     },
     data["employee"]
    }
  end

  # defp format({:admission, _data, info}) do
  defp format({_type, _data, employee}) do
    msg = %{
      name: Helper.proper_name(employee),
      email: employee["email"],
      cpf: employee["document"]["cpf"],
      internal_number: employee["id"],
      celphone: employee["cellphone"],
      groups: "1;2;3", # Name or id_group of groups of employee separated by semicolon
      leaders: pulses_supervisor(employee),
      language: "pt-BR",
      blocked: 0,
      sex: employee["gender"],
      birthday: employee["birth_date"],
      hiring_date: employee["hiring_date"],
      position: employee["job"]["name"]
    }

    {
      msg,
      #add pulses API URL
      # https://www.pulses.com.br/api/engage/v1/employees/
      Helper.slack_url()
    }
  end

  defp pulses_supervisor(employee) do
    #Name, CPF, internal_number of leaders of employee separated by semicolon
    supervisor = CB.Employees.find(employee["supervisor"]["id"])
    "#{Helper.proper_name(supervisor)}, #{supervisor["cpf"]}, #{supervisor["id"]}"
  end
end
