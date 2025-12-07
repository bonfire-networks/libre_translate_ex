defmodule LibreTranslate.LanguageTest do
  use ExUnit.Case, async: true

  import Mox

  alias LibreTranslate.Language

  setup :verify_on_exit!

  describe "get_languages/0" do
    test "get supported languages" do
      response = ~s"""
      [
        {"code": "en", "name": "English", "targets": ["ar", "de", "es", "fr"]},
        {"code": "fr", "name": "French", "targets": ["ar", "de", "en", "es"]}
      ]
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Language.get_languages() == {:ok, JSON.decode!(response)}
    end

    test "returns error on failure" do
      response = ~s"""
      {
        "error": "Service unavailable"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 500, body: response}}
      end)

      assert Language.get_languages() == {:error, "[500] Service unavailable"}
    end
  end

  describe "get_languages!/0" do
    test "get supported languages" do
      response = ~s"""
      [
        {"code": "en", "name": "English", "targets": ["ar", "de", "es", "fr"]}
      ]
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Language.get_languages!() == JSON.decode!(response)
    end
  end
end
