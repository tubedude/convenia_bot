defmodule CB do
  @moduledoc """
  CB keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  require Logger

  def process(data) do
    Logger.info("Starting process...")

    d = CB.ConveniaMsgs.parse(data)

    Logger.info("Process ended.")
    d
  end
end
