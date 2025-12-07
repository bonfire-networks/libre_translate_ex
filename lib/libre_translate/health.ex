defmodule LibreTranslate.Health do
  @moduledoc """
  Provides functions to check the health of a LibreTranslate instance.

  ## Examples

      iex> LibreTranslate.Health.check()
      {:ok, %{"status" => "ok"}}

      iex> LibreTranslate.Health.healthy?()
      true

  """
  @moduledoc since: "0.4.0"

  alias Req.Request

  @doc """
  Checks the health status of the LibreTranslate instance.

  ## Response

  On success, returns `{:ok, %{"status" => "ok"}}`.

  ## Examples

      iex> LibreTranslate.Health.check()
      {:ok, %{"status" => "ok"}}

  """
  @spec check() :: {:ok, map()} | {:error, String.t()}
  def check do
    {_request, response} =
      [
        method: :get,
        url: LibreTranslate.base_url() <> "/health",
        headers: [{"Accept", "application/json"}]
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    case response.status do
      200 ->
        {:ok, JSON.decode!(response.body)}

      status ->
        {:error, "[#{status}] Health check failed"}
    end
  end

  @doc """
  Returns true if the LibreTranslate instance is healthy.

  ## Examples

      iex> LibreTranslate.Health.healthy?()
      true

      iex> LibreTranslate.Health.healthy?()
      false

  """
  @spec healthy?() :: boolean()
  def healthy? do
    case check() do
      {:ok, %{"status" => "ok"}} -> true
      _ -> false
    end
  end
end
