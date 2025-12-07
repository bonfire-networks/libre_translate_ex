defmodule LibreTranslate.HTTPHelper do
  @moduledoc false
  @moduledoc since: "0.1.0"

  @doc """
  Returns the required headers for a LibreTranslate API request.

  LibreTranslate uses form-urlencoded requests, not JSON.
  """
  @spec required_request_headers() :: list(tuple())
  def required_request_headers do
    [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Accept", "application/json"}
    ]
  end

  @doc """
  Builds the form body for a LibreTranslate request.

  Adds the API key if configured.
  """
  @spec build_form_body(map()) :: String.t()
  def build_form_body(params) do
    params
    |> maybe_add_api_key()
    |> Map.reject(fn {_key, val} -> is_nil(val) end)
    |> URI.encode_query()
  end

  defp maybe_add_api_key(params) do
    case LibreTranslate.get_api_key() do
      nil -> params
      key -> Map.put(params, :api_key, key)
    end
  end

  @doc """
  Handles the response from the LibreTranslate API.

  It decodes the JSON body and returns a tuple with the status and decoded body.
  """
  @spec response(non_neg_integer(), binary()) :: {:ok, map() | list()} | {:error, String.t()}
  def response(status, body) when is_number(status) and is_binary(body) do
    case status do
      200 ->
        {:ok, JSON.decode!(body)}

      status when status in 400..599 ->
        decoded = JSON.decode!(body)
        error_message = decoded["error"] || "Unknown error"
        {:error, "[#{status}] #{error_message}"}

      _ ->
        {:error, "Unexpected response status: #{status}"}
    end
  end

  @doc """
  Handles the response from the LibreTranslate API.

  This function behaves like `response/2`, but raises an exception if the response is not
  successful.
  """
  @spec response!(non_neg_integer(), binary()) :: map() | list() | Exception.t()
  def response!(status, body) do
    case response(status, body) do
      {:ok, data} -> data
      {:error, reason} -> raise "HTTP Error: #{reason}"
    end
  end
end
