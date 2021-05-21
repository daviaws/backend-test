defmodule PlatformWeb.JWT.Plug do
  @moduledoc """
  This module give support to JWT bearer tokens.

  It decodes a bearer token and put it's :claims on conn.assigns

  To access claims: conn.assigns[:claims]
  Claims is a single Map.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias PlatformWeb.JWT.Token

  def init(opts), do: opts

  def call(conn, _opts) do
    token = get_bearer_token(conn)
    verify(conn, token)
  end

  defp verify(conn, nil) do
    conn
    |> put_status(:unauthorized)
    |> json(%{"message" => "Token não encontrado"})
    |> halt
  end

  defp verify(conn, token) do
    case Token.verify_and_validate(token) do
      {:ok, claims} ->
        conn |> success(claims)

      {:error, _error} ->
        conn |> forbidden
    end
  end

  defp req_authorization_header(conn) do
    conn
    |> Plug.Conn.get_req_header("authorization")
    |> List.first()
  end

  defp clean_token(dirty_token) do
    {token, _} = Regex.split(~r{\"}, dirty_token) |> List.pop_at(1)
    token
  end

  defp get_bearer_token(conn) do
    case req_authorization_header(conn) do
      nil ->
        nil

      dirty_token ->
        dirty_token |> clean_token
    end
  end

  defp success(conn, claims) do
    conn |> assign(:claims, claims)
  end

  defp forbidden(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{"message" => "Token expirado ou inválido"})
    |> halt
  end
end
