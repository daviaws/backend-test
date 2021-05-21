defmodule PlatformWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PlatformWeb, :controller

  # ToDo:
  # There is another possible way to do this.
  # http://joshwlewis.com/essays/elixir-error-handling-with-plug/
  # The tutorial says: It seems to work well with Ecto.Errors for instance
  def map_status(changeset) do
    case PlatformWeb.ChangesetView.translate_errors(changeset) do
      %{message: ["Usuário não existe"]} -> :not_found
      %{message: ["Post não existe"]} -> :not_found
      %{email: ["Usuário já existe"]} -> :conflict
      _ -> :bad_request
    end
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(map_status(changeset))
    |> put_view(PlatformWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(PlatformWeb.ErrorView)
    |> render(:"400")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(PlatformWeb.ErrorView)
    |> render(:"404")
  end
end
