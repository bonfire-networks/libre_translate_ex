defmodule LibreTranslate.Translator do
  @moduledoc """
  Provides functions to translate text using the LibreTranslate API.

  ## Examples

      # Simple translation
      iex> LibreTranslate.Translator.translate("Hello!", "en", "es")
      {:ok, %{"translatedText" => "¡Hola!"}}

      # Auto-detect source language
      iex> LibreTranslate.Translator.translate("Bonjour!", "auto", "en")
      {:ok,
       %{
         "detectedLanguage" => %{"confidence" => 90.0, "language" => "fr"},
         "translatedText" => "Hello!"
       }}

      # Translate HTML
      iex> LibreTranslate.Translator.translate("<p>Hello!</p>", "en", "es", format: "html")
      {:ok, %{"translatedText" => "<p>¡Hola!</p>"}}

      # Get alternative translations
      iex> LibreTranslate.Translator.translate("Hello", "en", "it", alternatives: 3)
      {:ok,
       %{
         "alternatives" => ["Salve", "Pronto"],
         "translatedText" => "Ciao"
       }}

  """
  @moduledoc since: "0.1.0"

  alias LibreTranslate.HTTPHelper
  alias LibreTranslate.Translator.TranslateRequest

  @type text :: binary()

  @doc """
  Translates the given text from source language to target language.

  ## Parameters

  - `text` - The text to translate
  - `source_lang` - Source language code (e.g., "en", "fr") or "auto" for auto-detection
  - `target_lang` - Target language code (e.g., "es", "de")
  - `opts` - Optional parameters

  ## Options

  - `:format` - Format of source text: "text" (default) or "html"
  - `:alternatives` - Number of alternative translations to return (integer)

  ## Response

  On success, returns `{:ok, response}` where response contains:

  - `"translatedText"` - The translated text
  - `"detectedLanguage"` - (when source is "auto") Map with "confidence" and "language"
  - `"alternatives"` - (when alternatives > 0) List of alternative translations

  ## Examples

      iex> LibreTranslate.Translator.translate("Hello World", "en", "id")
      {:ok, %{"translatedText" => "Halo Dunia"}}

      iex> LibreTranslate.Translator.translate("Hello", "en", "es", alternatives: 2)
      {:ok, %{"translatedText" => "Hola", "alternatives" => ["Saludos"]}}

  """
  @spec translate(text(), String.t(), String.t(), Keyword.t()) :: {:ok, map()} | {:error, String.t()}
  def translate(text, source_lang, target_lang, opts \\ []) when is_binary(text) do
    response = TranslateRequest.post_translate(text, source_lang, target_lang, opts)

    HTTPHelper.response(response.status, response.body)
  end

  @doc """
  Translates the given text from source language to target language.

  This function behaves like `translate/4`, but raises an error if the translation fails.
  """
  @spec translate!(text(), String.t(), String.t(), Keyword.t()) :: map()
  def translate!(text, source_lang, target_lang, opts \\ []) when is_binary(text) do
    response = TranslateRequest.post_translate(text, source_lang, target_lang, opts)

    HTTPHelper.response!(response.status, response.body)
  end
end
