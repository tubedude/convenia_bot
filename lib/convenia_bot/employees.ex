defmodule CB.Employees do
  use GenServer

  require Logger

  alias CB.ConveniaComm

  # Client
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def list() do
    GenServer.call(__MODULE__, :list)
  end

  def find(id) do
    GenServer.call(__MODULE__, {:find, id})
  end

  def reset() do
    GenServer.cast(__MODULE__, :reset)
  end

  def check_for_bday() do
    GenServer.call(__MODULE__, :birthday_reminder)
  end

  def check_admissions() do
    GenServer.call(__MODULE__, :next_admissions)
  end

  def updated() do
    GenServer.call(__MODULE__, :updated?)
  end

  # Callbacks

  @impl true
  @spec init(any()) :: {:ok, [any()]}
  def init(_args) do
    state =
      fetch_list()
      |> Enum.map(fn resp -> {resp["id"], resp, [bot_status: :raw]} end)

    enrich_list(state)

    {:ok, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:birthday_reminder, _from, state) do
    Logger.info("Starting birthday reminder.")

    case Enum.filter(state, &birthday?/1) do
      [] ->
        Logger.info("No cake today.")
        {:reply, [], state}

      nivers ->
        Logger.info("There is #{Enum.count(nivers)} birthday today.")
        data = %{"employees" => just(nivers), "type" => "birthday.reminder"}
        {:reply, CB.ExternalComm.post(data), state}
    end
  end

  def handle_call(:next_admissions, _from, state) do
    Logger.info("Starting admissions reminder.")

    case Enum.filter(state, &admission_is_near?/1) do
      [] ->
        Logger.info("No new admission found.")
        {:reply, [], state}

      employees ->
        Logger.info("Next admissions found: #{Enum.count(employees)}")
        data = %{"employees" => just(employees), "type" => "admissions.reminder"}
        {:reply, CB.ExternalComm.post(data), state}
    end
  end

  def handle_call({:find, search_id}, _from, state) do
    {_id, employee, _status} =
      state
      |> Enum.find(fn {id, _employee, _status} -> id == search_id end) ||
        fetch_employee(search_id)

    {:reply, employee, state}
  end

  def handle_call(:updated?, _from, state) do
    c =
      state
      |> Enum.filter(fn {_id, _employee, status} -> Map.has_key?(status, :bot_status) end)
      |> Enum.count()

    {:reply, c, state}
  end

  @impl true
  def handle_cast({:got_employee, {id, employee, status}}, state) do
    new_state =
      state
      |> Enum.map(fn {existing_id, _e, existing_status} = existing_data ->
        case existing_id == id do
          true -> {id, employee, Keyword.merge(existing_status, status)}
          false -> existing_data
        end
      end)

    {:noreply, new_state}
  end

  def handle_cast({:did_not_update, id}, state) do
    spawn(__MODULE__, :async_enrich_employee, [id])
    {:noreply, state}
  end

  def handle_cast(:reset, _state) do
    {:ok, state} = init([])
    {:noreply, state}
  end

  # Helpers

  defp birthday?({_id, employee, _status}),
    do: Date.diff(today(), parse_birthday(employee["birth_date"])) == 0

  defp admission_is_near?({_id, employee, _status}),
    do: Date.diff(today(), parse_date(employee["hiring_date"])) < 0

  defp today(), do: DateTime.to_date(DateTime.now!("America/Sao_Paulo"))

  defp fetch_employee(id), do: ConveniaComm.fetch_employee_info(id)

  defp fetch_list(), do: ConveniaComm.fetch_employees!()

  defp parse_date(date_string) do
    [date | _t] = String.split(date_string, " ")
    Date.from_iso8601!(date)
  end

  defp parse_birthday(date_string) do
    parse_date(date_string)
    |> (fn d -> Date.new!(today().year, d.month, d.day) end).()
  end

  defp enrich_list(state) do
    state
    |> Enum.map(fn {id, _e, _s} -> spawn(__MODULE__, :async_enrich_employee, [id]) end)
  end

  def async_enrich_employee(e) do
    case CB.ConveniaComm.fetch_employee_info(e, timeout: :infinity) do
      {:ok, employee} ->
        GenServer.cast(
          __MODULE__,
          {:got_employee, {employee["id"], employee, bot_status: :updated}}
        )

      {:error, _} ->
        GenServer.cast(__MODULE__, {:did_not_update, e})
    end
  end

  defp just(employees) do
    Enum.map(employees, fn {_id, e, _s} -> e end)
  end
end
