defmodule LibreTranslate.Translator.TranslateRequest do
  @moduledoc false
  @moduledoc since: "0.1.0"

  alias LibreTranslate.HTTPHelper
  alias Req.Request

  @type text :: binary() | list(binary())

  @doc """
  Sends a translation request to the LibreTranslate API.

  Constructs a request to translate the provided text into the specified target language.

  ## Parameters

  - `text` - The text(s) to translate (string or list of strings)
  - `source_lang` - Source language code or "auto" for auto-detection
  - `target_lang` - Target language code
  - `opts` - Optional parameters:
    - `:format` - "text" (default) or "html"
    - `:alternatives` - Number of alternative translations (integer)
  """
  @spec post_translate(text(), String.t(), String.t(), Keyword.t()) :: Req.Response.t() | Exception.t()
  def post_translate(text, source_lang, target_lang, opts \\ []) do
    params = %{
      q: text,
      source: source_lang,
      target: target_lang,
      format: Keyword.get(opts, :format),
      alternatives: Keyword.get(opts, :alternatives)
    }

    body = HTTPHelper.build_form_body(params)

    {_request, response} =
      [
        method: :post,
        url: LibreTranslate.base_url() <> "/translate",
        headers: HTTPHelper.required_request_headers(),
        body: body
      ]
      |> Request.new()
      |> LibreTranslate.Request.run_request()

    response
  end
end
