defmodule CBWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CBWeb do
    pipe_through :api

    get "/", ApiController, :check
  end

  scope "/api", CBWeb do
    pipe_through :api

    get "/:secret_user/:secret_pass/admissions", ApiController, :force_admissions_check
    post "/:secret_user/:secret_pass", ApiController, :incoming
  end
end
