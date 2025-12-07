Mox.defmock(LibreTranslate.MockRequest, for: LibreTranslate.Request)
Application.put_env(:libre_translate, :request_behaviour, LibreTranslate.MockRequest)

# Exclude integration tests by default (they require a real API)
# Run with: mix test --include integration
# Or: LIBRETRANSLATE_URL=http://localhost:5000 mix test --only integration
ExUnit.start(exclude: [:integration])
