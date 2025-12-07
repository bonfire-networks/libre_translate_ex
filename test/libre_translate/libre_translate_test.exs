defmodule LibreTranslateTest do
  use ExUnit.Case

  describe "get_api_key/0" do
    test "returns the API key from the application environment" do
      Application.put_env(:libre_translate_ex, :api_key, "test-api-key")

      assert LibreTranslate.get_api_key() == "test-api-key"
    end

    test "returns nil if the API key is not set" do
      Application.delete_env(:libre_translate_ex, :api_key)

      assert LibreTranslate.get_api_key() == nil
    end
  end

  describe "set_api_key/1" do
    test "sets the API key in the application environment" do
      assert LibreTranslate.set_api_key("test-api-key") == :ok
      assert LibreTranslate.get_api_key() == "test-api-key"
    end

    test "sets nil to remove the API key" do
      LibreTranslate.set_api_key("test-api-key")
      assert LibreTranslate.set_api_key(nil) == :ok
      assert LibreTranslate.get_api_key() == nil
    end
  end

  describe "base_url/0" do
    test "returns the default base URL when not configured" do
      Application.delete_env(:libre_translate_ex, :base_url)

      assert LibreTranslate.base_url() == "https://libretranslate.com"
    end

    test "returns the configured base URL" do
      Application.put_env(:libre_translate_ex, :base_url, "https://my-instance.com")

      assert LibreTranslate.base_url() == "https://my-instance.com"

      # Cleanup
      Application.delete_env(:libre_translate_ex, :base_url)
    end
  end

  describe "set_base_url/1" do
    test "sets the base URL in the application environment" do
      assert LibreTranslate.set_base_url("https://custom.libretranslate.com") == :ok
      assert LibreTranslate.base_url() == "https://custom.libretranslate.com"

      # Cleanup
      Application.delete_env(:libre_translate_ex, :base_url)
    end
  end
end
