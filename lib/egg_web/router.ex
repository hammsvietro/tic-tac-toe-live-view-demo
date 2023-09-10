defmodule EggWeb.Router do
  use EggWeb, :router

  import EggWeb.Identification

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EggWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :set_player_id
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EggWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/game/:id", GameLive
    live "/lobby", LobbyLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", EggWeb do
  #   pipe_through :api
  # end
end
