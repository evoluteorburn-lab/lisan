# Lisan - AI Translator

## Quick Start

```bash
git clone https://github.com/alexanderg/lisan.git
cd lisan
flutter pub get
flutter build apk --release
```

## Features
- Real-time speech translation (RU ↔ AR)
- AI-powered learning mode with explanations
- Voice output using ElevenLabs
- Save and organize translated phrases

## API Keys Required
- DeepL (translation)
- DeepSeek (explanations)
- ElevenLabs (voice)
- OpenAI (speech recognition)

See `.env.example` for configuration.

## Build

### Local
```bash
flutter build apk --release
```

### Docker
```bash
./build_docker.sh
```

## License
MIT
