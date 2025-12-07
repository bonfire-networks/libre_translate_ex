defmodule LibreTranslate.HealthTest do
  use ExUnit.Case, async: true

  import Mox

  alias LibreTranslate.Health

  setup :verify_on_exit!

  describe "check/0" do
    test "returns ok status when healthy" do
      response = ~s"""
      {"status": "ok"}
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Health.check() == {:ok, %{"status" => "ok"}}
    end

    test "returns error on failure" do
      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 503, body: ""}}
      end)

      assert Health.check() == {:error, "[503] Health check failed"}
    end
  end

  describe "healthy?/0" do
    test "returns true when status is ok" do
      response = ~s"""
      {"status": "ok"}
      """

      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 200, body: response}}
      end)

      assert Health.healthy?() == true
    end

    test "returns false on error" do
      expect(LibreTranslate.MockRequest, :run_request, fn _request ->
        {%Req.Request{}, %Req.Response{status: 500, body: ""}}
      end)

      assert Health.healthy?() == false
    end
  end
end
