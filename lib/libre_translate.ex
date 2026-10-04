defmodule LibreTranslate do
  @moduledoc """
  Provide base functions for the LibreTranslate API.

  LibreTranslate is a free and open source machine translation API.
  It can be self-hosted or used via libretranslate.com.

  ## Configuration

  Configure the base URL and optionally an API key:

      config :libre_translate_ex,
        base_url: "https://libretranslate.com",
        api_key: "your-api-key"  # optional for self-hosted instances

  """
  @moduledoc since: "0.1.0"

  @default_base_url "https://libretranslate.com"

  @doc """
  Get the currently active API key.

  Returns `nil` if no API key is configured, which is valid for self-hosted instances.

  ## Examples

      iex> LibreTranslate.get_api_key()
      "your-api-key"

      iex> LibreTranslate.get_api_key()
      nil

  """
  @spec get_api_key(Keyword.t()) :: String.t() | nil
  # an `:api_key` option is for one request only, e.g. when each user can have their own
  def get_api_key(opts \\ []),
    do: opts[:api_key] || Application.get_env(:libre_translate_ex, :api_key)

  @doc """
  Set the API key in the application environment.

  ## Examples

      iex> LibreTranslate.set_api_key("your-api-key")
      :ok

  """
  @spec set_api_key(String.t() | nil) :: :ok
  def set_api_key(key), do: Application.put_env(:libre_translate_ex, :api_key, key)

  @doc """
  Get the base URL for the LibreTranslate API.

  Returns the configured base URL, or defaults to "https://libretranslate.com".

  ## Examples

      iex> LibreTranslate.base_url()
      "https://libretranslate.com"

  """
  @spec base_url(Keyword.t()) :: String.t()
  # a `:base_url` option is for one request only, e.g. when each user can have their own server
  def base_url(opts \\ []),
    do: opts[:base_url] || Application.get_env(:libre_translate_ex, :base_url, @default_base_url)

  @doc """
  Set the base URL in the application environment.

  ## Examples

      iex> LibreTranslate.set_base_url("https://my-libretranslate-instance.com")
      :ok

  """
  @spec set_base_url(String.t()) :: :ok
  def set_base_url(url), do: Application.put_env(:libre_translate_ex, :base_url, url)
end
