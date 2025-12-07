defmodule LibreTranslate.FileTranslator do
  @moduledoc """
  Provides functions to translate files using the LibreTranslate API.

  ## Examples

      iex> LibreTranslate.FileTranslator.translate_file("/path/to/file.txt", "en", "es")
      {:ok, "¡Hola mundo!"}

  """
  @moduledoc since: "0.4.0"

  alias Req.Request

  @doc """
  Translates the contents of a file from source language to target language.

  ## Parameters

  - `file_path` - Path to the file to translate
  - `source_lang` - Source language code (e.g., "en", "fr") or "auto" for auto-detection
  - `target_lang` - Target language code (e.g., "es", "de")

  ## Response

  On success, returns `{:ok, translated_content}` where translated_content is the
  translated file content as a string.

  ## Examples

      iex> LibreTranslate.FileTranslator.translate_file("document.txt", "en", "es")
      {:ok, "Contenido traducido del archivo..."}

      iex> LibreTranslate.FileTranslator.translate_file("page.html", "auto", "fr")
      {:ok, "<html>Contenu traduit...</html>"}

  """
  @spec translate_file(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def translate_file(file_path, source_lang, target_lang) when is_binary(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        do_translate_file(file_path, content, source_lang, target_lang)

      {:error, reason} ->
        {:error, "Failed to read file: #{inspect(reason)}"}
    end
  end

  @doc """
  Translates the contents of a file from source language to target language.

  This function behaves like `translate_file/3`, but raises an error if the translation fails.
  """
  @spec translate_file!(String.t(), String.t(), String.t()) :: String.t()
  def translate_file!(file_path, source_lang, target_lang) when is_binary(file_path) do
    case translate_file(file_path, source_lang, target_lang) do
      {:ok, result} -> result
      {:error, reason} -> raise "File translation error: #{reason}"
    end
  end

  defp do_translate_file(file_path, content, source_lang, target_lang) do
    # Build multipart form data
    filename = Path.basename(file_path)

    multipart =
      {:multipart,
       [
         {:file, content,
          {"form-data", [{"name", "file"}, {"filename", filename}]},
          []},
         {"source", source_lang},
         {"target", target_lang}
       ] ++ maybe_api_key_part()}

    {_request, response} =
      [
        method: :post,
        url: LibreTranslate.base_url() <> "/translate_file",
        headers: [{"Accept", "application/json"}],
        body: multipart
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    handle_file_response(response.status, response.body)
  end

  defp maybe_api_key_part do
    case LibreTranslate.get_api_key() do
      nil -> []
      key -> [{"api_key", key}]
    end
  end

  defp handle_file_response(200, body) when is_binary(body) do
    case JSON.decode(body) do
      {:ok, %{"translatedFileUrl" => url}} ->
        # If the API returns a URL, fetch the translated content
        fetch_translated_file(url)

      {:ok, %{"translatedText" => text}} ->
        {:ok, text}

      {:ok, data} when is_binary(data) ->
        {:ok, data}

      {:error, _} ->
        # Response might be the translated file content directly
        {:ok, body}
    end
  end

  defp handle_file_response(status, body) when status in 400..599 do
    case JSON.decode(body) do
      {:ok, %{"error" => error}} -> {:error, "[#{status}] #{error}"}
      _ -> {:error, "[#{status}] Unknown error"}
    end
  end

  defp handle_file_response(status, _body) do
    {:error, "Unexpected response status: #{status}"}
  end

  defp fetch_translated_file(url) do
    {_request, response} =
      [
        method: :get,
        url: url,
        headers: [{"Accept", "*/*"}]
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    case response.status do
      200 -> {:ok, response.body}
      status -> {:error, "[#{status}] Failed to fetch translated file"}
    end
  end
end
