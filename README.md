# LibreTranslate

[LibreTranslate](https://libretranslate.com) is a free and open source machine translation API. It can be self-hosted or used via libretranslate.com.

`libre_translate_ex` is a **community-maintained** Elixir client library for the LibreTranslate API.

## Requirements

To use `libre_translate_ex`, your environment must meet these requirements:

- **Erlang**: Version `27.0` or later
- **Elixir**: Version `1.18.0-otp-27` or later

## Installation

Add `libre_translate_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:libre_translate_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

Configure the base URL and optionally an API key:

```elixir
# config/config.exs
config :libre_translate_ex,
  base_url: "https://libretranslate.com",  # or your self-hosted instance
  api_key: "your-api-key"  # optional for self-hosted instances without auth
```

Or set at runtime:

```elixir
LibreTranslate.set_base_url("https://my-libretranslate-instance.com")
LibreTranslate.set_api_key("my-api-key")
```

## Usage

### Translate text

```elixir
iex> LibreTranslate.Translator.translate("Hello!", "en", "es")
{:ok, %{"translatedText" => "¡Hola!"}}

# Auto-detect source language
iex> LibreTranslate.Translator.translate("Bonjour!", "auto", "en")
{:ok,
 %{
   "detectedLanguage" => %{"confidence" => 90.0, "language" => "fr"},
   "translatedText" => "Hello!"
 }}

# Translate HTML
iex> LibreTranslate.Translator.translate("<p>Hello!</p>", "en", "es", format: "html")
{:ok, %{"translatedText" => "<p>¡Hola!</p>"}}

# Get alternative translations
iex> LibreTranslate.Translator.translate("Hello", "en", "it", alternatives: 3)
{:ok,
 %{
   "alternatives" => ["Salve", "Pronto"],
   "translatedText" => "Ciao"
 }}
```

### Detect language

```elixir
iex> LibreTranslate.Detector.detect("Bonjour!")
{:ok, [%{"confidence" => 90.0, "language" => "fr"}]}
```

### Get supported languages

```elixir
iex> LibreTranslate.Language.get_languages()
{:ok,
 [
   %{"code" => "en", "name" => "English", "targets" => ["ar", "de", "es", ...]},
   %{"code" => "fr", "name" => "French", "targets" => ["ar", "de", "en", ...]}
 ]}
```

### Translate files

```elixir
iex> LibreTranslate.FileTranslator.translate_file("document.txt", "en", "es")
{:ok, "Contenido traducido..."}
```

### Health check

```elixir
iex> LibreTranslate.Health.healthy?()
true

iex> LibreTranslate.Health.check()
{:ok, %{"status" => "ok"}}
```

## License

This package is licensed under the [MIT License](https://github.com/bonfire-networks/libre_translate_ex/blob/main/LICENSE.md).

The code was originally based on https://github.com/muzhawir/deepl
