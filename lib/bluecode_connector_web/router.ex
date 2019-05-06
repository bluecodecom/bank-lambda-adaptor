defmodule BluecodeConnectorWeb.Router do
  use BluecodeConnectorWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    # Out of scope for ECB Hackathon: adding basic auth, etc.
  end

  scope "/wizard", BluecodeConnectorWeb.Onboarding do
    pipe_through(:browser)

    get("/", WizardController, :index)
    get("/new", WizardController, :new)
    get("/callback", WizardController, :callback)
  end

  scope "/clearing/", BluecodeConnectorWeb.ClearingApi do
    pipe_through(:api)

    post("/payment", ClearingController, :payment)
  end

  scope "/clearing", BluecodeConnectorWeb.Clearing do
    pipe_through :api

    post "/payment", PaymentController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", BluecodeConnectorWeb do
  #   pipe_through :api
  # end
end
