defmodule LibreTranslate.Language do
  @moduledoc """
  Provides functions to get the list of supported languages from LibreTranslate.
  """
  @moduledoc since: "0.3.0"

  alias LibreTranslate.HTTPHelper
  alias Req.Request

  @doc """
  Get the list of supported languages.

  Returns a list of supported languages with their codes, names, and supported targets.

  ## Response

  On success, returns `{:ok, languages}` where languages is a list of maps containing:

  - `"code"` - Language code (e.g., "en", "fr")
  - `"name"` - Human-readable language name in English (e.g., "English", "French")
  - `"targets"` - List of supported target language codes for this source language

  ## Examples

      iex> LibreTranslate.Language.get_languages()
      {:ok,
       [
         %{"code" => "en", "name" => "English", "targets" => ["ar", "de", "es", "fr", ...]},
         %{"code" => "fr", "name" => "French", "targets" => ["ar", "de", "en", "es", ...]}
       ]}

  """
  @spec get_languages() :: {:ok, list(map())} | {:error, String.t()}
  def get_languages do
    {_request, response} =
      [
        method: :get,
        url: LibreTranslate.base_url() <> "/languages",
        headers: [{"Accept", "application/json"}]
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    HTTPHelper.response(response.status, response.body)
  end

  @doc """
  Get the list of supported languages.

  This function behaves like `get_languages/0`, but raises an error if the request fails.
  """
  @spec get_languages!() :: list(map())
  def get_languages! do
    {_request, response} =
      [
        method: :get,
        url: LibreTranslate.base_url() <> "/languages",
        headers: [{"Accept", "application/json"}]
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    HTTPHelper.response!(response.status, response.body)
  end
end
