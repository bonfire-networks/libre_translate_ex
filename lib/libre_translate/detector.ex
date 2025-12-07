defmodule LibreTranslate.Detector do
  @moduledoc """
  Provides functions to detect the language of text using the LibreTranslate API.

  ## Examples

      iex> LibreTranslate.Detector.detect("Bonjour!")
      {:ok, [%{"confidence" => 90.0, "language" => "fr"}]}

  """
  @moduledoc since: "0.4.0"

  alias LibreTranslate.HTTPHelper
  alias Req.Request

  @doc """
  Detects the language of the given text.

  Returns a list of detected languages with their confidence scores.

  ## Parameters

  - `text` - The text to detect the language of

  ## Response

  On success, returns `{:ok, detections}` where detections is a list of maps containing:

  - `"language"` - The detected language code (e.g., "fr", "en")
  - `"confidence"` - Confidence score (0-100)

  ## Examples

      iex> LibreTranslate.Detector.detect("Bonjour!")
      {:ok, [%{"confidence" => 90.0, "language" => "fr"}]}

      iex> LibreTranslate.Detector.detect("Hello world!")
      {:ok, [%{"confidence" => 95.0, "language" => "en"}]}

  """
  @spec detect(String.t()) :: {:ok, list(map())} | {:error, String.t()}
  def detect(text) when is_binary(text) do
    body = HTTPHelper.build_form_body(%{q: text})

    {_request, response} =
      [
        method: :post,
        url: LibreTranslate.base_url() <> "/detect",
        headers: HTTPHelper.required_request_headers(),
        body: body
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    HTTPHelper.response(response.status, response.body)
  end

  @doc """
  Detects the language of the given text.

  This function behaves like `detect/1`, but raises an error if the detection fails.
  """
  @spec detect!(String.t()) :: list(map())
  def detect!(text) when is_binary(text) do
    body = HTTPHelper.build_form_body(%{q: text})

    {_request, response} =
      [
        method: :post,
        url: LibreTranslate.base_url() <> "/detect",
        headers: HTTPHelper.required_request_headers(),
        body: body
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    HTTPHelper.response!(response.status, response.body)
  end
end
