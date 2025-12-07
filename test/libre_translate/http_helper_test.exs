defmodule LibreTranslate.HTTPHelperTest do
  use ExUnit.Case, async: true

  alias LibreTranslate.HTTPHelper

  describe "required_request_headers/0" do
    test "returns form-urlencoded content type and json accept" do
      assert HTTPHelper.required_request_headers() == [
               {"Content-Type", "application/x-www-form-urlencoded"},
               {"Accept", "application/json"}
             ]
    end
  end

  describe "build_form_body/1" do
    test "builds form body without api_key when not configured" do
      Application.delete_env(:libre_translate_ex, :api_key)

      body = HTTPHelper.build_form_body(%{q: "Hello", source: "en", target: "es"})

      assert body =~ "q=Hello"
      assert body =~ "source=en"
      assert body =~ "target=es"
      refute body =~ "api_key"
    end

    test "builds form body with api_key when configured" do
      Application.put_env(:libre_translate_ex, :api_key, "test-key")

      body = HTTPHelper.build_form_body(%{q: "Hello", source: "en", target: "es"})

      assert body =~ "q=Hello"
      assert body =~ "api_key=test-key"

      # Cleanup
      Application.delete_env(:libre_translate_ex, :api_key)
    end

    test "filters out nil values" do
      Application.delete_env(:libre_translate_ex, :api_key)

      body = HTTPHelper.build_form_body(%{q: "Hello", format: nil, alternatives: nil})

      assert body == "q=Hello"
    end
  end

  describe "response/2" do
    test "returns {:ok, data} for 200 status" do
      body = ~s'{"translatedText": "Hola"}'

      assert HTTPHelper.response(200, body) == {:ok, %{"translatedText" => "Hola"}}
    end

    test "returns {:error, message} for 400 status" do
      body = ~s'{"error": "Invalid request"}'

      assert HTTPHelper.response(400, body) == {:error, "[400] Invalid request"}
    end

    test "returns {:error, message} for 500 status" do
      body = ~s'{"error": "Server error"}'

      assert HTTPHelper.response(500, body) == {:error, "[500] Server error"}
    end
  end

  describe "response!/2" do
    test "returns data for 200 status" do
      body = ~s'{"translatedText": "Hola"}'

      assert HTTPHelper.response!(200, body) == %{"translatedText" => "Hola"}
    end

    test "raises for error status" do
      body = ~s'{"error": "Invalid request"}'

      assert_raise RuntimeError, "HTTP Error: [400] Invalid request", fn ->
        HTTPHelper.response!(400, body)
      end
    end
  end
end
