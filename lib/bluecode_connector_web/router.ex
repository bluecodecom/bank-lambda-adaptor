defmodule BluecodeConnectorWeb.Router do
  use BluecodeConnectorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/wizard", BluecodeConnectorWeb.Onboarding do
    pipe_through :browser

    get "/", WizardController, :index
    get "/new", WizardController, :new
    get "/callback", WizardController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", BluecodeConnectorWeb do
  #   pipe_through :api
  # end
end
