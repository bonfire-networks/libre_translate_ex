defmodule LibreTranslate.TranslatorTest do
  use ExUnit.Case, async: true

  import Mox

  alias LibreTranslate.Translator

  setup :verify_on_exit!

  describe "translate/4" do
    test "translate text with source and target language" do
      response = ~s"""
      {
        "translatedText": "¡Hola!"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Translator.translate("Hello!", "en", "es") == {:ok, JSON.decode!(response)}
    end

    test "translate with auto-detection returns detected language" do
      response = ~s"""
      {
        "detectedLanguage": {
          "confidence": 90.0,
          "language": "fr"
        },
        "translatedText": "Hello!"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Translator.translate("Bonjour!", "auto", "en") == {:ok, JSON.decode!(response)}
    end

    test "translate HTML content" do
      response = ~s"""
      {
        "translatedText": "<p class=\\"green\\">¡Hola!</p>"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Translator.translate("<p class=\"green\">Hello!</p>", "en", "es", format: "html") ==
               {:ok, JSON.decode!(response)}
    end

    test "translate with alternatives" do
      response = ~s"""
      {
        "alternatives": ["Salve", "Pronto"],
        "translatedText": "Ciao"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Translator.translate("Hello", "en", "it", alternatives: 3) ==
               {:ok, JSON.decode!(response)}
    end

    test "returns {:error, reason} on invalid input" do
      response = ~s"""
      {
        "error": "Invalid target language"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 400, body: response}}
      end)

      assert Translator.translate("Hello World", "en", "invalid") ==
               {:error, "[400] Invalid target language"}
    end
  end

  describe "translate!/4" do
    test "translate text successfully" do
      response = ~s"""
      {
        "translatedText": "Halo Dunia"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Translator.translate!("Hello World", "en", "id") == JSON.decode!(response)
    end

    test "raises an error on invalid input" do
      response = ~s"""
      {
        "error": "Invalid target language"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 400, body: response}}
      end)

      assert_raise RuntimeError, "HTTP Error: [400] Invalid target language", fn ->
        Translator.translate!("Hello World", "en", "invalid")
      end
    end
  end
end
