defmodule LibreTranslate.IntegrationTest do
  @moduledoc """
  Integration tests that run against a real LibreTranslate API.

  To run these tests, set the LIBRETRANSLATE_URL environment variable:

      LIBRETRANSLATE_URL=https://libretranslate.com mix test --only integration

  Or for a local instance:

      LIBRETRANSLATE_URL=http://localhost:5000 mix test --only integration

  If the API requires authentication, also set:

      LIBRETRANSLATE_API_KEY=your-api-key

  """
  use ExUnit.Case

  @moduletag :integration

  setup do
    # Use the real Req.Request instead of the mock
    Application.put_env(:libre_translate, :request_behaviour, Req.Request)

    url = System.get_env("LIBRETRANSLATE_URL", "https://libretranslate.com")
    api_key = System.get_env("LIBRETRANSLATE_API_KEY")

    LibreTranslate.set_base_url(url)
    LibreTranslate.set_api_key(api_key)

    on_exit(fn ->
      # Restore mock for other tests
      Application.put_env(:libre_translate, :request_behaviour, LibreTranslate.MockRequest)
    end)

    :ok
  end

  describe "Health.check/0" do
    test "returns healthy status" do
      result = LibreTranslate.Health.check()

      assert {:ok, %{"status" => "ok"}} = result
    end

    test "healthy?/0 returns true" do
      assert LibreTranslate.Health.healthy?() == true
    end
  end

  describe "Language.get_languages/0" do
    test "returns list of supported languages" do
      {:ok, languages} = LibreTranslate.Language.get_languages()

      assert is_list(languages)
      assert length(languages) > 0

      # Check structure of first language
      first = hd(languages)
      assert Map.has_key?(first, "code")
      assert Map.has_key?(first, "name")
      assert Map.has_key?(first, "targets")
    end
  end

  describe "Translator.translate/4" do
    test "translates English to Spanish" do
      {:ok, result} = LibreTranslate.Translator.translate("Hello", "en", "es")

      assert Map.has_key?(result, "translatedText")
      # "Hola" is the expected translation, but could vary
      assert is_binary(result["translatedText"])
    end

    test "translates with auto-detection" do
      {:ok, result} = LibreTranslate.Translator.translate("Bonjour", "auto", "en")

      assert Map.has_key?(result, "translatedText")
      assert Map.has_key?(result, "detectedLanguage")
      assert result["detectedLanguage"]["language"] == "fr"
    end

    test "translates HTML content" do
      {:ok, result} =
        LibreTranslate.Translator.translate(
          "<p>Hello</p>",
          "en",
          "es",
          format: "html"
        )

      assert result["translatedText"] =~ "<p>"
      assert result["translatedText"] =~ "</p>"
    end

    test "returns alternatives when requested" do
      {:ok, result} =
        LibreTranslate.Translator.translate(
          "Hello",
          "en",
          "es",
          alternatives: 2
        )

      assert Map.has_key?(result, "translatedText")
      # Alternatives may or may not be present depending on the API
    end

    test "translate!/4 returns result directly" do
      result = LibreTranslate.Translator.translate!("Hello", "en", "es")

      assert Map.has_key?(result, "translatedText")
    end
  end

  describe "Detector.detect/1" do
    test "detects English" do
      {:ok, detections} = LibreTranslate.Detector.detect("Hello world")

      assert is_list(detections)
      assert length(detections) > 0

      first = hd(detections)
      assert first["language"] == "en"
      assert is_number(first["confidence"])
    end

    test "detects French" do
      {:ok, detections} = LibreTranslate.Detector.detect("Bonjour le monde")

      assert is_list(detections)
      first = hd(detections)
      assert first["language"] == "fr"
    end

    test "detects Spanish" do
      {:ok, detections} = LibreTranslate.Detector.detect("Hola mundo")

      assert is_list(detections)
      first = hd(detections)
      assert first["language"] == "es"
    end

    test "detect!/1 returns result directly" do
      detections = LibreTranslate.Detector.detect!("Hola mundo")

      assert is_list(detections)
      first = hd(detections)
      assert first["language"] == "es"
    end
  end
end
