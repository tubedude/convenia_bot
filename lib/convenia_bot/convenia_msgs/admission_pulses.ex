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
  defp format({_type, _data, info}) do
    msg = %{
      name: info["name"],
      email: info["email"]
      # add json msg to Pulses
    }

    {
      msg,
      #add pulses API URL
      Helper.slack_url()
    }
  end
end
