defmodule LibreTranslate.FileTranslatorTest do
  use ExUnit.Case, async: true

  import Mox

  alias LibreTranslate.FileTranslator

  setup :verify_on_exit!

  describe "translate_file/3" do
    test "returns error when file does not exist" do
      result = FileTranslator.translate_file("/nonexistent/file.txt", "en", "es")

      assert {:error, message} = result
      assert message =~ "Failed to read file"
    end

    test "translates file content successfully" do
      # Create a temporary file
      tmp_path = Path.join(System.tmp_dir!(), "test_translate_#{:rand.uniform(10000)}.txt")
      File.write!(tmp_path, "Hello world")

      response = ~s"""
      {"translatedText": "Hola mundo"}
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert FileTranslator.translate_file(tmp_path, "en", "es") == {:ok, "Hola mundo"}

      # Cleanup
      File.rm(tmp_path)
    end

    test "returns error on API failure" do
      tmp_path = Path.join(System.tmp_dir!(), "test_translate_#{:rand.uniform(10000)}.txt")
      File.write!(tmp_path, "Hello world")

      response = ~s"""
      {"error": "Unsupported file format"}
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 400, body: response}}
      end)

      assert FileTranslator.translate_file(tmp_path, "en", "es") ==
               {:error, "[400] Unsupported file format"}

      # Cleanup
      File.rm(tmp_path)
    end
  end

  describe "translate_file!/3" do
    test "raises on file not found" do
      assert_raise RuntimeError, ~r/Failed to read file/, fn ->
        FileTranslator.translate_file!("/nonexistent/file.txt", "en", "es")
      end
    end

    test "raises on API failure" do
      tmp_path = Path.join(System.tmp_dir!(), "test_translate_#{:rand.uniform(10000)}.txt")
      File.write!(tmp_path, "Hello world")

      response = ~s"""
      {"error": "Translation failed"}
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 500, body: response}}
      end)

      assert_raise RuntimeError, ~r/Translation failed/, fn ->
        FileTranslator.translate_file!(tmp_path, "en", "es")
      end

      # Cleanup
      File.rm(tmp_path)
    end
  end
end
