defmodule BankAccountWeb.Router do
  use BankAccountWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_authenticated do
    plug :accepts, ["json"]
    plug BankAccountWeb.AuthAccessPipeline
  end

  scope "/api/v1", BankAccountWeb do
    pipe_through :api

    patch("/customers/update", Customer.RegisterController, :update)
  end

  scope "/api/v1", BankAccountWeb do
    pipe_through :api_authenticated

    post("/customers/indications", Customer.IndicationsController, :show)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BankAccountWeb.Telemetry
    end
  end
end
