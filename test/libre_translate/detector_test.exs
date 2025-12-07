defmodule LibreTranslate.DetectorTest do
  use ExUnit.Case, async: true

  import Mox

  alias LibreTranslate.Detector

  setup :verify_on_exit!

  describe "detect/1" do
    test "detects language with confidence" do
      response = ~s"""
      [
        {"confidence": 90.0, "language": "fr"}
      ]
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Detector.detect("Bonjour!") == {:ok, JSON.decode!(response)}
    end

    test "detects multiple possible languages" do
      response = ~s"""
      [
        {"confidence": 80.0, "language": "en"},
        {"confidence": 15.0, "language": "de"}
      ]
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Detector.detect("Hello") == {:ok, JSON.decode!(response)}
    end

    test "returns error on failure" do
      response = ~s"""
      {
        "error": "Invalid request"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 400, body: response}}
      end)

      assert Detector.detect("") == {:error, "[400] Invalid request"}
    end
  end

  describe "detect!/1" do
    test "detects language successfully" do
      response = ~s"""
      [
        {"confidence": 95.0, "language": "en"}
      ]
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Detector.detect!("Hello world") == JSON.decode!(response)
    end

    test "raises on failure" do
      response = ~s"""
      {
        "error": "Service unavailable"
      }
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 500, body: response}}
      end)

      assert_raise RuntimeError, "HTTP Error: [500] Service unavailable", fn ->
        Detector.detect!("test")
      end
    end
  end
end
