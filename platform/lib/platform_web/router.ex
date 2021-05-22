defmodule PlatformWeb.Router do
  use PlatformWeb, :router

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

  pipeline :authenticatedApi do
    plug :accepts, ["json"]

    plug PlatformWeb.JWT.Plug
  end

  scope "/", PlatformWeb do
    pipe_through :api

    post "/user", UserController, :create

    post "/login", LoginController, :create
  end

  scope "/", PlatformWeb do
    pipe_through :authenticatedApi

    get "/user", UserController, :index
    get "/user/:id", UserController, :show
    delete "/user/me", UserController, :delete

    get "/post", PostController, :index
    # "/search?q=:search" matches :show method too
    get "/post/:id", PostController, :show
    post "/post", PostController, :create
    put "/post/:id", PostController, :update
    delete "/post/:id", PostController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlatformWeb do
  #   pipe_through :api
  # end

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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PlatformWeb.Telemetry
    end
  end
end
